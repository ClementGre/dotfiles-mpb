// Shows the current weather icon and temperature, from CoreLocation and Open-Meteo (free, no key).
// Replaces a Shortcuts shortcut, which posted an error notification whenever it couldn't get the
// location and sometimes hung. Refreshed every 10 minutes, on wake and on unlock, never while the
// screen is locked (asleep, or night maintenance wakes). On failure the last weather stays shown,
// hidden after 3 failures in a row (30 minutes stale).
//   weather <icon item> <label item> [--print]
import AppKit
import CoreLocation

let arguments = CommandLine.arguments.filter { $0 != "--print" }
let printOnly = CommandLine.arguments.contains("--print")
guard arguments.count == 3 else {
  FileHandle.standardError.write("usage: weather <icon item> <label item> [--print]\n".data(using: .utf8)!)
  exit(2)
}
let iconItem = arguments[1]
let labelItem = arguments[2]

let refreshInterval: TimeInterval = 600
let maxFailures = 3
// An older position is still fine for the weather if a fresh one can't be had
let maxLocationAge: TimeInterval = 6 * 3600

@Sendable func send(_ message: String) {
  if printOnly {
    print(message)
    fflush(stdout)
    return
  }
  var bytes = Array(message.utf8CString)
  bytes.withUnsafeMutableBufferPointer { sketchybar($0.baseAddress) }
}

@Sendable func log(_ message: String) {
  FileHandle.standardError.write("weather: \(message)\n".data(using: .utf8)!)
}

@Sendable func screenLocked() -> Bool {
  let session = CGSessionCopyCurrentDictionary() as? [String: Any]
  return session?["CGSSessionScreenIsLocked"] as? Bool ?? false
}

// WMO weather codes, as used by Open-Meteo
@Sendable func icon(code: Int, windSpeed: Double) -> String {
  switch code {
  case 95...99: return "⛈️"
  case 71...77, 85, 86: return "❄️"
  case 51...67, 80...82: return "🌧️"
  case 45, 48: return "🌫️"
  case _ where windSpeed >= 30: return "💨"
  case 0: return "☀️"
  case 1, 2: return "🌤️"
  default: return "☁️"
  }
}

struct Forecast: Decodable {
  struct Current: Decodable {
    let temperature_2m: Double
    let weather_code: Int
    let wind_speed_10m: Double
  }
  let current: Current
}

final class Weather: NSObject, CLLocationManagerDelegate {
  let locationManager = CLLocationManager()
  var failures = 0
  // Set while waiting for the location and the forecast, given up after 2 minutes if they hang
  var updateStarted: Date?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func update() {
    if let updateStarted, -updateStarted.timeIntervalSinceNow < 120 { return }
    if updateStarted != nil { failed() }
    updateStarted = nil
    guard !screenLocked() else { return }
    switch locationManager.authorizationStatus {
    case .notDetermined:
      // Asks once, update() runs again from locationManagerDidChangeAuthorization
      log("asking for location access")
      locationManager.requestWhenInUseAuthorization()
    case .denied, .restricted:
      log("location access denied, allow it in Settings > Privacy & Security > Location Services")
      failed()
    default:
      updateStarted = Date()
      locationManager.requestLocation()
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus != .notDetermined { update() }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    fetch(location.coordinate)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let location = manager.location, -location.timestamp.timeIntervalSinceNow < maxLocationAge {
      fetch(location.coordinate)
    } else {
      log("no location: \(error.localizedDescription)")
      updateStarted = nil
      failed()
    }
  }

  func fetch(_ coordinate: CLLocationCoordinate2D) {
    var url = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
    url.queryItems = [
      URLQueryItem(name: "latitude", value: String(format: "%.2f", coordinate.latitude)),
      URLQueryItem(name: "longitude", value: String(format: "%.2f", coordinate.longitude)),
      URLQueryItem(name: "current", value: "temperature_2m,weather_code,wind_speed_10m"),
    ]
    var request = URLRequest(url: url.url!)
    request.timeoutInterval = 30
    URLSession.shared.dataTask(with: request) { data, _, error in
      let forecast = data.flatMap { try? JSONDecoder().decode(Forecast.self, from: $0) }
      DispatchQueue.main.async {
        self.updateStarted = nil
        guard let current = forecast?.current else {
          log("no weather: \(error?.localizedDescription ?? "unexpected response")")
          self.failed()
          return
        }
        self.failures = 0
        let temperature = "\(Int(current.temperature_2m.rounded())) °C"
        send("--set \(iconItem) drawing=on icon=\(icon(code: current.weather_code, windSpeed: current.wind_speed_10m))"
          + " --set \(labelItem) drawing=on label=\"\(temperature)\"")
      }
    }.resume()
  }

  func failed() {
    failures += 1
    if failures == maxFailures {
      send("--set \(iconItem) drawing=off --set \(labelItem) drawing=off")
    }
  }
}

let weather = Weather()
let workspace = NSWorkspace.shared.notificationCenter
// Delayed so the network and location services are back
workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
  DispatchQueue.main.asyncAfter(deadline: .now() + 10) { weather.update() }
}
DistributedNotificationCenter.default().addObserver(forName: .init("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
  DispatchQueue.main.asyncAfter(deadline: .now() + 5) { weather.update() }
}

weather.update()
Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in weather.update() }
RunLoop.main.run()
