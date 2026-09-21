// Shows a sketchybar item while a Focus (Do Not Disturb, ...) is on, dimmed or hidden when off.
// macOS 27 exposes no readable Focus state (the DND database needs Full Disk Access), so this reads
// the native Focus icon in MenuBarAgent: set to always show, it is drawn at 45% opacity when no
// Focus is on and 90% when one is; set to "When Active", it only exists while one is on.
// Checked on accessibility notifications and every half second.
//   focus <item> <off: dim|hide> <color> <dimmed color> [--print]
import AppKit
import ApplicationServices

let arguments = CommandLine.arguments.filter { $0 != "--print" }
let printOnly = CommandLine.arguments.contains("--print")
guard arguments.count == 5 else {
  FileHandle.standardError.write("usage: focus <item> <dim|hide> <color> <dimmed color> [--print]\n".data(using: .utf8)!)
  exit(2)
}
let item = arguments[1]
let hideWhenOff = arguments[2] == "hide"
let color = arguments[3]
let dimmedColor = arguments[4]

let focusIdentifier = "com.apple.menuextra.focusmode"
var observedPid: pid_t = 0
var observer: AXObserver?
var lastMessage = ""

@Sendable func send(_ message: String) {
  if printOnly {
    print(message)
    fflush(stdout)
    return
  }
  var bytes = Array(message.utf8CString)
  bytes.withUnsafeMutableBufferPointer { sketchybar($0.baseAddress) }
}

@Sendable func menuBarAgentPid() -> pid_t? {
  NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.MenuBarAgent").first?.processIdentifier
}

@Sendable func children(of element: AXUIElement) -> [AXUIElement] {
  var value: CFTypeRef?
  AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &value)
  return value as? [AXUIElement] ?? []
}

// The opacity macOS draws the icon with, from its accessibility description's text color
@Sendable func iconOpacity(_ icon: AXUIElement) -> CGFloat? {
  var description: CFTypeRef?
  AXUIElementCopyAttributeValue(icon, "AXAttributedDescription" as CFString, &description)
  guard let text = description as? NSAttributedString, text.length > 0,
        let color = text.attribute(NSAttributedString.Key("AXForegroundColor"), at: 0, effectiveRange: nil)
  else { return nil }
  return CFGetTypeID(color as CFTypeRef) == CGColor.typeID ? (color as! CGColor).alpha : nil
}

// Apple icons are each wrapped in an AXGroup of MenuBarAgent's extras menu bar
@Sendable func focusActive(pid: pid_t) -> Bool {
  var extras: CFTypeRef?
  let app = AXUIElementCreateApplication(pid)
  guard AXUIElementCopyAttributeValue(app, "AXExtrasMenuBar" as CFString, &extras) == .success,
        let extras, CFGetTypeID(extras) == AXUIElementGetTypeID() else { return false }
  for group in children(of: extras as! AXUIElement) {
    for icon in children(of: group) {
      var identifier: CFTypeRef?
      AXUIElementCopyAttributeValue(icon, kAXIdentifierAttribute as CFString, &identifier)
      guard identifier as? String == focusIdentifier else { continue }
      // No readable opacity: fall back to the icon's presence ("When Active" setting)
      return (iconOpacity(icon) ?? 1) >= 0.7
    }
  }
  return false
}

// Instant updates when MenuBarAgent adds or removes an icon (re-attached if it restarts)
@Sendable func observe(pid: pid_t) {
  if let observer {
    CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .defaultMode)
  }
  observer = nil
  observedPid = pid
  var newObserver: AXObserver?
  guard AXObserverCreate(pid, { _, _, _, _ in update() }, &newObserver) == .success, let newObserver else { return }
  let app = AXUIElementCreateApplication(pid)
  for notification in [kAXCreatedNotification, kAXUIElementDestroyedNotification, kAXLayoutChangedNotification,
                       kAXValueChangedNotification, kAXTitleChangedNotification] {
    AXObserverAddNotification(newObserver, app, notification as CFString, nil)
  }
  CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(newObserver), .defaultMode)
  observer = newObserver
}

@Sendable func update() {
  guard let pid = menuBarAgentPid() else { return }
  if pid != observedPid { observe(pid: pid) }

  let message: String
  if focusActive(pid: pid) {
    message = "--set \(item) drawing=on icon.color=\(color)"
  } else if hideWhenOff {
    message = "--set \(item) drawing=off"
  } else {
    message = "--set \(item) drawing=on icon.color=\(dimmedColor)"
  }
  if message != lastMessage {
    lastMessage = message
    send(message)
  }
}

guard AXIsProcessTrusted() else {
  FileHandle.standardError.write("focus: no accessibility permission\n".data(using: .utf8)!)
  exit(1)
}
update()
Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in update() }
RunLoop.main.run()
