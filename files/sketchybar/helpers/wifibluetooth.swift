// Colors the Wi-Fi icon by signal strength (red to green) and sets the Bluetooth icon by connected
// device count. Reads CoreWLAN and IOBluetooth in-process instead of running `sudo wdutil info`,
// a full diagnostics dump that kept airportd busy. Wi-Fi updates instantly on link quality
// notifications, Bluetooth on connect notifications, both are also checked every few seconds.
//   wifibluetooth <wifi item> <bluetooth item> [--print]
import CoreWLAN
import Foundation
import IOBluetooth

let arguments = CommandLine.arguments.filter { $0 != "--print" }
let printOnly = CommandLine.arguments.contains("--print")
guard arguments.count == 3 else {
  FileHandle.standardError.write("usage: wifibluetooth <wifi item> <bluetooth item> [--print]\n".data(using: .utf8)!)
  exit(2)
}
let wifiItem = arguments[1]
let bluetoothItem = arguments[2]

let foreground = "0xffffffff"
let dimmed = "0xff929598"
let bluetoothColor = "0xff0082FC"
let wifiIcon = "􀙇"
let wifiOffIcon = "􀙈"
let bluetoothOffIcon = "󰂲"
let bluetoothDisconnectedIcon = "󰂯"
let bluetoothConnectedIcons = ["󰂱", "󰂰", "󰂳", "󰂴"] // 1, 2, 3, 4+ devices

var lastWifi = ""
var lastBluetooth = ""

@Sendable func send(_ message: String) {
  if printOnly {
    print(message)
    fflush(stdout)
    return
  }
  var bytes = Array(message.utf8CString)
  bytes.withUnsafeMutableBufferPointer { sketchybar($0.baseAddress) }
}

// Hue from red (-90 dBm and below) to green (-50 dBm and above), as an ARGB hex color
@Sendable func signalColor(rssi: Int) -> String {
  let t = Double(min(-50, max(-90, rssi)) + 90) / 40
  let h = t * 120 / 60, i = Int(h), f = h - Double(i)
  let v = 0.9, p = 0.0, q = v * (1 - f), u = v * f
  let (r, g, b): (Double, Double, Double) = [(v, u, p), (q, v, p), (p, v, u)][min(i, 2)]
  return String(format: "0xff%02x%02x%02x", Int(r * 255), Int(g * 255), Int(b * 255))
}

@Sendable func updateWifi() {
  let message: String
  if let interface = CWWiFiClient.shared().interface(), interface.powerOn() {
    // The SSID needs location access, the channel is enough to know we are associated
    let connected = interface.wlanChannel() != nil && interface.rssiValue() != 0
    let color = connected ? signalColor(rssi: interface.rssiValue()) : dimmed
    message = "--set \(wifiItem) icon=\(wifiIcon) icon.color=\(color)"
  } else {
    message = "--set \(wifiItem) icon=\(wifiOffIcon) icon.color=\(dimmed)"
  }
  if message != lastWifi {
    lastWifi = message
    send("--animate sin 5 " + message)
  }
}

@Sendable func updateBluetooth() {
  let message: String
  if IOBluetoothHostController.default()?.powerState != kBluetoothHCIPowerStateON {
    message = "--set \(bluetoothItem) icon=\(bluetoothOffIcon) icon.color=\(dimmed)"
  } else {
    let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
    let connected = devices.filter { $0.isConnected() }.count
    if connected > 0 {
      let icon = bluetoothConnectedIcons[min(connected, 4) - 1]
      message = "--set \(bluetoothItem) icon=\(icon) icon.color=\(bluetoothColor)"
    } else {
      message = "--set \(bluetoothItem) icon=\(bluetoothDisconnectedIcon) icon.color=\(dimmed)"
    }
  }
  if message != lastBluetooth {
    lastBluetooth = message
    send("--animate sin 5 " + message)
  }
}

final class Events: NSObject, CWEventDelegate {
  func linkQualityDidChangeForWiFiInterface(withName interfaceName: String, rssi: Int, transmitRate: Double) {
    DispatchQueue.main.async(execute: updateWifi)
  }
  func linkDidChangeForWiFiInterface(withName interfaceName: String) {
    DispatchQueue.main.async(execute: updateWifi)
  }
  func powerStateDidChangeForWiFiInterface(withName interfaceName: String) {
    DispatchQueue.main.async(execute: updateWifi)
  }

  // Each connected device then notifies its own disconnection
  @objc func connected(_ notification: IOBluetoothUserNotification, device: IOBluetoothDevice) {
    device.register(forDisconnectNotification: self, selector: #selector(disconnected(_:device:)))
    updateBluetooth()
  }
  @objc func disconnected(_ notification: IOBluetoothUserNotification, device: IOBluetoothDevice) {
    notification.unregister()
    updateBluetooth()
  }
}

let events = Events()
let client = CWWiFiClient.shared()
client.delegate = events
for event in [CWEventType.linkQualityDidChange, .linkDidChange, .powerDidChange] {
  try? client.startMonitoringEvent(with: event)
}
// Also fires once for every device already connected
IOBluetoothDevice.register(forConnectNotifications: events, selector: #selector(Events.connected(_:device:)))

updateWifi()
updateBluetooth()
// Bluetooth power changes have no notification, and link quality events are only a hint
Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
  updateWifi()
  updateBluetooth()
}
RunLoop.main.run()
