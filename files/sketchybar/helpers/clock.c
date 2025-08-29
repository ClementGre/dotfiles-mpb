#include "sketchybar.h"
#include <CoreFoundation/CoreFoundation.h>
#include <time.h>
#include <locale.h>

void callback(CFRunLoopTimerRef timer, void* info) {
  time_t current_time;
  time(&current_time);
  setlocale(LC_TIME, "fr_FR.UTF-8");

  struct tm* tm_info = localtime(&current_time);

  // Custom French month abbreviations
  const char* months[] = {
    "jan.", "fév.", "mars", "avril", "mai", "juin",
    "juil.", "août", "sept.", "oct.", "nov.", "déc."
  };

  char buffer1[64];
  // Format: weekday day month hour:
  strftime(buffer1, sizeof(buffer1), "%a. %d", tm_info);
  snprintf(buffer1 + strlen(buffer1), sizeof(buffer1) - strlen(buffer1), " %s %02d:",
           months[tm_info->tm_mon],
           tm_info->tm_hour);

  char buffer2[64];
  strftime(buffer2, sizeof(buffer2), "%M:%S", tm_info);


  uint32_t message_size = sizeof(buffer1) + sizeof(buffer2) + 64;
  char message[message_size];
  snprintf(message, message_size, "--set time1 label=\"%s\" --set time2 label=\"%s\"", buffer1, buffer2);

  sketchybar(message);
}

int main() {
  CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault, (int64_t) CFAbsoluteTimeGetCurrent() + 1.0, 1.0, 0, 0, callback, NULL);
  CFRunLoopAddTimer(CFRunLoopGetMain(), timer, kCFRunLoopDefaultMode);
  CFRunLoopRun();
  return 0;
}
