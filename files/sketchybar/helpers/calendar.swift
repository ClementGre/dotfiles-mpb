// Shows the current / next calendar events in sketchybar (calendar_title and calendar_time).
// Events come from EventKit, the macOS calendar store (BusyCal has no API to read them, and its
// accounts are the same). Updates live when a calendar changes; `--print` prints instead of sending.
import EventKit
import Foundation

let excludedCalendars: Set<String> = ["Routine", "ADE Direct"]
let maxEvents = 4
let maxTitleLength = 20
let rotationPeriod: TimeInterval = 30  // every event is shown in turn over this period

func color(of calendar: String) -> String {
  if calendar == "INSA" { return "0xFFFFCC99" }  // Light engineering orange
  if calendar == "Personnel" { return "0xFF99CCFF" }  // Light blue
  if calendar == "SIA" { return "0xFFCC99FF" }  // Light purple
  if calendar.hasPrefix("UL") { return "0xFFFF9D99" }  // Light red
  return "0xFFFFFFFF"
}

let printOnly = CommandLine.arguments.contains("--print")
let store = EKEventStore()
var events: [EKEvent] = []
var lastMessage = ""

let timeFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "HH:mm"
  return formatter
}()
let dayFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "dd/MM"
  return formatter
}()

// "dans 1h 05min", or beyond 6 hours "demain à 14:00"
func delta(to date: Date, from now: Date) -> String {
  let seconds = Int(abs(date.timeIntervalSince(now)))
  if seconds / 3600 <= 6 {
    return String(format: "dans %dh %02dmin", seconds / 3600, (seconds % 3600) / 60)
  }
  let calendar = Calendar.current
  let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now),
                                     to: calendar.startOfDay(for: date)).day ?? 0
  let day: String
  switch days {
  case 0: day = "aujourd’hui"
  case 1: day = "demain"
  case 2: day = "après-demain"
  default: day = "le \(dayFormatter.string(from: date))"
  }
  let time = timeFormatter.string(from: date)
  return time == "00:00" ? day : "\(day) à \(time)"
}

func truncated(_ title: String) -> String {
  title.count > maxTitleLength ? String(title.prefix(maxTitleLength - 3)) + "..." : title
}

// sketchybar.h's message parser drops ' and breaks on " inside labels
func escaped(_ text: String) -> String {
  text.replacingOccurrences(of: "\"", with: "”").replacingOccurrences(of: "'", with: "’")
}

func send(_ message: String) {
  if printOnly {
    print(message)
    return
  }
  var bytes = Array(message.utf8CString)
  bytes.withUnsafeMutableBufferPointer { sketchybar($0.baseAddress) }
}

// Today's and tomorrow's events that haven't ended yet
func reloadEvents() {
  let now = Date()
  let calendar = Calendar.current
  let end = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: now))!
  let calendars = store.calendars(for: .event).filter { !excludedCalendars.contains($0.title) }
  guard !calendars.isEmpty else {
    events = []
    return
  }
  let predicate = store.predicateForEvents(withStart: now, end: end, calendars: calendars)
  events = Array(store.events(matching: predicate)
    .filter { $0.endDate > now }
    .sorted { $0.startDate < $1.startDate }
    .prefix(maxEvents))
}

func update() {
  let now = Date()
  if events.contains(where: { $0.endDate <= now }) { reloadEvents() }

  let message: String
  if events.isEmpty {
    message = "--set calendar_title label=\"\" --set calendar_time label=\"\""
  } else {
    let slot = rotationPeriod / Double(events.count)
    let event = events[Int(now.timeIntervalSince1970 / slot) % events.count]
    let time = event.startDate <= now
      ? "Fin \(delta(to: event.endDate, from: now))"
      : "Début \(delta(to: event.startDate, from: now))"
    message = "--set calendar_title label=\"\(escaped(truncated(event.title ?? "")))\""
      + " label.color=\(color(of: event.calendar.title))"
      + " --set calendar_time label=\"\(escaped(time))\""
  }
  if message != lastMessage {
    lastMessage = message
    send(message)
  }
}

func start() {
  reloadEvents()
  update()
  NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: store, queue: .main) { _ in
    reloadEvents()
    update()
  }
  // Labels only change on rotation or minute boundaries: sent only when they do
  Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in update() }
  // Picks up the next day's events and anything the change notification missed
  Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in reloadEvents() }
}

store.requestFullAccessToEvents { granted, error in
  DispatchQueue.main.async {
    guard granted else {
      FileHandle.standardError.write("Calendar access denied: \(error?.localizedDescription ?? "")\n".data(using: .utf8)!)
      send("--set calendar_title label=\"\" --set calendar_time label=\"Accès au calendrier refusé\"")
      exit(1)
    }
    start()
  }
}
RunLoop.main.run()
