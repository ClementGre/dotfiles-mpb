// Waits for the next mouse click anywhere and prints where it was released: "x y"
// Counts button-up events rather than polling the button state, so even a trackpad tap shorter
// than the polling interval is seen (and no Accessibility / Input Monitoring permission is needed).
#include <ApplicationServices/ApplicationServices.h>
#include <stdio.h>
#include <unistd.h>

bool button_down() {
  return CGEventSourceButtonState(kCGEventSourceStateCombinedSessionState, kCGMouseButtonLeft)
      || CGEventSourceButtonState(kCGEventSourceStateCombinedSessionState, kCGMouseButtonRight);
}

uint32_t clicks() {
  return CGEventSourceCounterForEventType(kCGEventSourceStateCombinedSessionState, kCGEventLeftMouseUp)
       + CGEventSourceCounterForEventType(kCGEventSourceStateCombinedSessionState, kCGEventRightMouseUp);
}

int main() {
  uint32_t start = clicks();
  // The click that launched us may still be held: its release doesn't count
  if (button_down()) start++;
  while (clicks() <= start) usleep(20000);

  CGEventRef event = CGEventCreate(NULL);
  CGPoint location = CGEventGetLocation(event);
  CFRelease(event);
  printf("%.0f %.0f\n", location.x, location.y);
  return 0;
}
