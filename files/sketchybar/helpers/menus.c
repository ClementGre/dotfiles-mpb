#include <Carbon/Carbon.h>
#include <libproc.h>
#include <signal.h>

void ax_init() {
  const void *keys[] = { kAXTrustedCheckOptionPrompt };
  const void *values[] = { kCFBooleanTrue };

  CFDictionaryRef options;
  options = CFDictionaryCreate(kCFAllocatorDefault,
                               keys,
                               values,
                               sizeof(keys) / sizeof(*keys),
                               &kCFCopyStringDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks     );

  bool trusted = AXIsProcessTrustedWithOptions(options);
  CFRelease(options);
  if (!trusted) exit(1);
}

void ax_perform_click(AXUIElementRef element) {
  if (!element) return;
  AXUIElementPerformAction(element, kAXCancelAction);
  usleep(150000);
  AXUIElementPerformAction(element, kAXPressAction);
}

CFStringRef ax_get_title(AXUIElementRef element) {
  CFTypeRef title = NULL;
  AXError error = AXUIElementCopyAttributeValue(element,
                                                kAXTitleAttribute,
                                                &title            );

  if (error != kAXErrorSuccess) return NULL;
  return title;
}

// Since macOS 27, opening an app menu no longer reveals the auto-hidden menu bar, but hovering
// its invisible titles still switches menus. Park the cursor just below it so it can't.
void park_cursor_below_menu_bar(AXUIElementRef item) {
  CGSize size = CGSizeZero;
  CFTypeRef size_ref = NULL;
  if (AXUIElementCopyAttributeValue(item, kAXSizeAttribute, &size_ref) == kAXErrorSuccess) {
    AXValueGetValue(size_ref, kAXValueCGSizeType, &size);
    CFRelease(size_ref);
  }
  CGEventRef event = CGEventCreate(NULL);
  CGPoint cursor = CGEventGetLocation(event);
  CFRelease(event);

  CGDirectDisplayID display;
  uint32_t count = 0;
  if (CGGetDisplaysWithPoint(cursor, 1, &display, &count) != kCGErrorSuccess || count == 0) return;
  double below = CGDisplayBounds(display).origin.y + (size.height > 0 ? size.height : 33) + 2;
  if (cursor.y >= below) return;
  CGWarpMouseCursorPosition(CGPointMake(cursor.x, below));
  CGAssociateMouseAndMouseCursorPosition(true);
}

void ax_select_menu_option(AXUIElementRef app, int id) {
  AXUIElementRef menubars_ref = NULL;
  CFArrayRef children_ref = NULL;

  AXError error = AXUIElementCopyAttributeValue(app,
                                                kAXMenuBarAttribute,
                                                (CFTypeRef*)&menubars_ref);
  if (error == kAXErrorSuccess) {
    error = AXUIElementCopyAttributeValue(menubars_ref,
                                          kAXVisibleChildrenAttribute,
                                          (CFTypeRef*)&children_ref   );

    if (error == kAXErrorSuccess) {
      uint32_t count = CFArrayGetCount(children_ref);
      if (id < count) {
        AXUIElementRef item = CFArrayGetValueAtIndex(children_ref, id);
        park_cursor_below_menu_bar(item);
        ax_perform_click(item);
      }
      if (children_ref) CFRelease(children_ref);
    }
    if (menubars_ref) CFRelease(menubars_ref);
  }
}

void ax_print_menu_options(AXUIElementRef app) {
  AXUIElementRef menubars_ref = NULL;
  CFArrayRef children_ref = NULL;

  AXError error = AXUIElementCopyAttributeValue(app,
                                                kAXMenuBarAttribute,
                                                (CFTypeRef*)&menubars_ref);
  if (error == kAXErrorSuccess) {
    error = AXUIElementCopyAttributeValue(menubars_ref,
                                          kAXVisibleChildrenAttribute,
                                          (CFTypeRef*)&children_ref   );

    if (error == kAXErrorSuccess) {
      uint32_t count = CFArrayGetCount(children_ref);

      for (int i = 1; i < count; i++) {
        AXUIElementRef item = CFArrayGetValueAtIndex(children_ref, i);
        CFTypeRef title = ax_get_title(item);

        if (title) {
          CFIndex strLen = CFStringGetLength((CFStringRef)title);
          CFIndex maxLen = CFStringGetMaximumSizeForEncoding(strLen, kCFStringEncodingUTF8) + 1;
          UInt8 *buffer = (UInt8 *)malloc(maxLen);
          if (buffer) {
            CFIndex usedBufLen = 0;
            CFIndex converted = CFStringGetBytes(
              (CFStringRef)title,
              CFRangeMake(0, strLen),
              kCFStringEncodingUTF8,
              0, // lossByte
              false, // isExternalRepresentation
              buffer,
              maxLen - 1,
              &usedBufLen
            );
            if (converted > 0) {
              buffer[usedBufLen] = '\0';
              printf("%s\n", buffer);
            } else {
              printf("<unprintable>\n");
            }
            free(buffer);
          } else {
            printf("<memory error>\n");
          }
          CFRelease(title);
        }
      }
    }
    if (menubars_ref) CFRelease(menubars_ref);
    if (children_ref) CFRelease(children_ref);
  }
}

pid_t pid_for_process_name(const char* name) {
  pid_t pids[4096];
  int count = proc_listallpids(pids, sizeof(pids));
  for (int i = 0; i < count; i++) {
    char path[PROC_PIDPATHINFO_MAXSIZE];
    if (proc_pidpath(pids[i], path, sizeof(path)) <= 0) continue;
    const char* base = strrchr(path, '/');
    if (base && strcmp(base + 1, name) == 0) return pids[i];
  }
  return 0;
}

bool ax_identifier_equals(AXUIElementRef element, const char* identifier) {
  CFTypeRef value = NULL;
  AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute, &value);
  if (!value) return false;
  char buffer[256];
  bool equal = CFGetTypeID(value) == CFStringGetTypeID()
               && CFStringGetCString(value, buffer, sizeof(buffer), kCFStringEncodingUTF8)
               && strcmp(buffer, identifier) == 0;
  CFRelease(value);
  return equal;
}

// target is either an Apple item identifier (com.apple.menuextra.wifi), which since macOS 27
// lives in MenuBarAgent wrapped in an AXGroup, or an app process name (first item is used).
AXUIElementRef ax_get_extra_menu_item(char* target) {
  bool apple = strncmp(target, "com.apple.menuextra.", 20) == 0;
  pid_t pid = pid_for_process_name(apple ? "MenuBarAgent" : target);
  if (!pid) return NULL;

  AXUIElementRef app = AXUIElementCreateApplication(pid);
  if (!app) return NULL;
  AXUIElementRef result = NULL;
  CFTypeRef extras = NULL;
  CFArrayRef children_ref = NULL;
  if (AXUIElementCopyAttributeValue(app, kAXExtrasMenuBarAttribute, &extras) == kAXErrorSuccess
      && AXUIElementCopyAttributeValue(extras, kAXChildrenAttribute, (CFTypeRef*)&children_ref) == kAXErrorSuccess) {
    uint32_t count = CFArrayGetCount(children_ref);
    for (uint32_t i = 0; i < count && !result; i++) {
      AXUIElementRef child = CFArrayGetValueAtIndex(children_ref, i);
      if (!apple) {
        result = (AXUIElementRef)CFRetain(child);
        break;
      }
      CFArrayRef group_children = NULL;
      if (AXUIElementCopyAttributeValue(child, kAXChildrenAttribute, (CFTypeRef*)&group_children) != kAXErrorSuccess)
        continue;
      for (CFIndex j = 0; j < CFArrayGetCount(group_children); j++) {
        AXUIElementRef item = CFArrayGetValueAtIndex(group_children, j);
        if (ax_identifier_equals(item, target)) {
          result = (AXUIElementRef)CFRetain(item);
          break;
        }
      }
      CFRelease(group_children);
    }
  }

  if (children_ref) CFRelease(children_ref);
  if (extras) CFRelease(extras);
  CFRelease(app);
  return result;
}

void ax_copy_string(AXUIElementRef element, CFStringRef attribute, char* buffer, size_t size) {
  snprintf(buffer, size, "-");
  CFTypeRef value = NULL;
  AXUIElementCopyAttributeValue(element, attribute, &value);
  if (!value) return;
  if (CFGetTypeID(value) == CFStringGetTypeID() && CFStringGetLength(value) > 0)
    CFStringGetCString(value, buffer, size, kCFStringEncodingUTF8);
  CFRelease(value);
}

// "/Applications/Foo.app/Contents/MacOS/foo" -> app name "Foo" and its bundle identifier
void app_bundle_info(const char* path, char* name, size_t name_size, char* bundle_id, size_t id_size) {
  snprintf(name, name_size, "-");
  snprintf(bundle_id, id_size, "-");
  const char* app_end = strstr(path, ".app/Contents/MacOS/");
  if (!app_end) return;
  const char* start = app_end;
  while (start > path && *(start - 1) != '/') start--;
  snprintf(name, name_size, "%.*s", (int)(app_end - start), start);

  char bundle_path[PATH_MAX];
  snprintf(bundle_path, sizeof(bundle_path), "%.*s", (int)(app_end - path + 4), path);
  CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*)bundle_path, strlen(bundle_path), true);
  if (!url) return;
  CFBundleRef bundle = CFBundleCreate(NULL, url);
  if (bundle) {
    CFStringRef identifier = CFBundleGetIdentifier(bundle);
    if (identifier) CFStringGetCString(identifier, bundle_id, id_size, kCFStringEncodingUTF8);
    CFRelease(bundle);
  }
  CFRelease(url);
}

// Lists every menu bar icon, tab separated:
//   <target for -s>  <app name>  <bundle id>  <description>  <actions>
// Apple icons have "Apple" as app name; an app's extra icons are noted in their description.
void ax_print_menu_extras() {
  pid_t agent = pid_for_process_name("MenuBarAgent");
  pid_t pids[4096];
  int count = proc_listallpids(pids, sizeof(pids));
  for (int i = 0; i < count; i++) {
    char path[PROC_PIDPATHINFO_MAXSIZE];
    if (proc_pidpath(pids[i], path, sizeof(path)) <= 0) continue;
    // Menu bar icons belong to app bundles
    if (!strstr(path, ".app/Contents/MacOS/")) continue;
    const char* name = strrchr(path, '/') + 1;

    AXUIElementRef app = AXUIElementCreateApplication(pids[i]);
    if (!app) continue;
    AXUIElementSetMessagingTimeout(app, 0.25);
    CFTypeRef extras = NULL;
    CFArrayRef children_ref = NULL;
    if (AXUIElementCopyAttributeValue(app, kAXExtrasMenuBarAttribute, &extras) == kAXErrorSuccess
        && AXUIElementCopyAttributeValue(extras, kAXChildrenAttribute, (CFTypeRef*)&children_ref) == kAXErrorSuccess) {
      char app_name[256], bundle_id[256];
      app_bundle_info(path, app_name, sizeof(app_name), bundle_id, sizeof(bundle_id));
      for (CFIndex j = 0; j < CFArrayGetCount(children_ref); j++) {
        AXUIElementRef child = CFArrayGetValueAtIndex(children_ref, j);
        char buffer[256];
        if (pids[i] != agent) {
          ax_copy_string(child, kAXDescriptionAttribute, buffer, sizeof(buffer));
          if (j > 0) {
            char extra[64];
            snprintf(extra, sizeof(extra), " (item %ld, -s only opens the first)", (long)j + 1);
            strlcat(buffer, extra, sizeof(buffer));
          }
          char actions[256] = "";
          CFArrayRef action_names = NULL;
          if (AXUIElementCopyActionNames(child, &action_names) == kAXErrorSuccess && action_names) {
            for (CFIndex k = 0; k < CFArrayGetCount(action_names); k++) {
              char action[64];
              if (!CFStringGetCString(CFArrayGetValueAtIndex(action_names, k), action, sizeof(action), kCFStringEncodingUTF8)) continue;
              if (actions[0]) strlcat(actions, ",", sizeof(actions));
              strlcat(actions, action, sizeof(actions));
            }
            CFRelease(action_names);
          }
          printf("%s\t%s\t%s\t%s\t%s\n", name, app_name, bundle_id, buffer, actions[0] ? actions : "none");
          continue;
        }
        // Apple items: each wrapped in a group, addressed by identifier
        CFArrayRef group_children = NULL;
        if (AXUIElementCopyAttributeValue(child, kAXChildrenAttribute, (CFTypeRef*)&group_children) != kAXErrorSuccess)
          continue;
        for (CFIndex k = 0; k < CFArrayGetCount(group_children); k++) {
          ax_copy_string(CFArrayGetValueAtIndex(group_children, k), kAXIdentifierAttribute, buffer, sizeof(buffer));
          printf("%s\tApple\t-\t-\t-\n", buffer);
        }
        CFRelease(group_children);
      }
    }
    if (children_ref) CFRelease(children_ref);
    if (extras) CFRelease(extras);
    CFRelease(app);
  }
}

#define MAX_POPUPS 64

// Fills ids with the on-screen popup menu windows, returns their count
int popup_menu_windows(uint32_t* ids) {
  CFArrayRef window_list = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly,
                                                      kCGNullWindowID                );
  if (!window_list) return 0;
  int count = 0;
  for (CFIndex i = 0; i < CFArrayGetCount(window_list) && count < MAX_POPUPS; i++) {
    CFDictionaryRef dictionary = CFArrayGetValueAtIndex(window_list, i);
    CFNumberRef layer_ref = CFDictionaryGetValue(dictionary, kCGWindowLayer);
    CFNumberRef id_ref = CFDictionaryGetValue(dictionary, kCGWindowNumber);
    CFDictionaryRef bounds_ref = CFDictionaryGetValue(dictionary, kCGWindowBounds);
    if (!layer_ref || !id_ref || !bounds_ref) continue;
    int layer = 0;
    CFNumberGetValue(layer_ref, kCFNumberIntType, &layer);
    CGRect bounds = CGRectNull;
    CGRectMakeWithDictionaryRepresentation(bounds_ref, &bounds);
    // Some apps park their popover off-screen instead of closing it
    if (layer != kCGPopUpMenuWindowLevel || bounds.origin.x < 0) continue;
    CFNumberGetValue(id_ref, kCFNumberSInt32Type, &ids[count++]);
  }
  CFRelease(window_list);
  return count;
}

bool contains_id(uint32_t* ids, int count, uint32_t id) {
  for (int i = 0; i < count; i++) if (ids[i] == id) return true;
  return false;
}

// Popups in after that are not in before
int new_popups(uint32_t* before, int before_count, uint32_t* after, int after_count, uint32_t* out) {
  int count = 0;
  for (int i = 0; i < after_count; i++)
    if (!contains_id(before, before_count, after[i])) out[count++] = after[i];
  return count;
}

// The latest helper owns the menu bar: an older one (e.g. Wi-Fi still open when clicking
// Control Center) must not restore it while a newer one keeps it hidden.
const char* owner_file() {
  static char path[PATH_MAX];
  if (!path[0]) {
    char dir[PATH_MAX] = "/tmp/";
    confstr(_CS_DARWIN_USER_TEMP_DIR, dir, sizeof(dir));
    snprintf(path, sizeof(path), "%s/sketchybar_menus_extra.pid", dir);
  }
  return path;
}

void claim_menu_bar() {
  FILE* file = fopen(owner_file(), "w");
  if (!file) return;
  fprintf(file, "%d", getpid());
  fclose(file);
}

bool newer_helper_running() {
  FILE* file = fopen(owner_file(), "r");
  if (!file) return false;
  int pid = 0;
  if (fscanf(file, "%d", &pid) != 1) pid = 0;
  fclose(file);
  return pid > 0 && pid != getpid() && kill(pid, 0) == 0;
}

extern int SLSMainConnectionID();
extern void SLSSetMenuBarVisibilityOverrideOnDisplay(int cid, int did, bool enabled);
extern void SLSSetMenuBarInsetAndAlpha(int cid, double u1, double u2, float alpha);

// Waits up to tries * 50ms for popups that were not open before, returns their count
int wait_for_new_popups(uint32_t* before, int before_count, uint32_t* opened, int tries) {
  uint32_t current[MAX_POPUPS];
  for (int i = 0; i < tries; i++) {
    usleep(50000);
    int count = new_popups(before, before_count, current, popup_menu_windows(current), opened);
    if (count > 0) return count;
  }
  return 0;
}

// Opens a menu bar icon (item) or runs command (e.g. an app's own "open menu" CLI) with the
// native menu bar made transparent, until every menu it opened is closed
void open_with_hidden_menu_bar(AXUIElementRef item, const char* command) {
  claim_menu_bar();
  uint32_t before[MAX_POPUPS], current[MAX_POPUPS], opened[MAX_POPUPS];
  int before_count = popup_menu_windows(before);

  int cid = SLSMainConnectionID();
  SLSSetMenuBarInsetAndAlpha(cid, 0, 1, 0.0);
  SLSSetMenuBarVisibilityOverrideOnDisplay(cid, 0, true);
  SLSSetMenuBarInsetAndAlpha(cid, 0, 1, 0.0);

  int opened_count = 0;
  if (command) {
    system(command);
    opened_count = wait_for_new_popups(before, before_count, opened, 20);
  } else {
    // No cancel + delay here (unlike ax_perform_click): the bar is already forced visible
    AXUIElementPerformAction(item, kAXPressAction);
    opened_count = wait_for_new_popups(before, before_count, opened, 8);
    if (opened_count == 0) {
      AXUIElementPerformAction(item, kAXShowMenuAction);
      opened_count = wait_for_new_popups(before, before_count, opened, 8);
    }
  }

  // The override dies with this process, so stay alive for as long as that popup is open.
  // Only set the alpha once: every call re-applies the inset too, which redraws the bar.
  while (opened_count > 0) {
    usleep(100000);
    int current_count = popup_menu_windows(current);
    bool still_open = false;
    for (int i = 0; i < opened_count && !still_open; i++)
      still_open = contains_id(current, current_count, opened[i]);
    if (!still_open) break;
  }

  while (!newer_helper_running()) {
    // Another menu may still be open (e.g. switched to a neighbouring item): wait for it too
    if (popup_menu_windows(current) > 0) {
      usleep(100000);
      continue;
    }
    // Let the bar collapse while still transparent, then make it opaque again
    SLSSetMenuBarVisibilityOverrideOnDisplay(cid, 0, false);
    usleep(1000000);
    if (newer_helper_running() || popup_menu_windows(current) > 0) continue;
    SLSSetMenuBarInsetAndAlpha(cid, 0, 1, 1.0);
    unlink(owner_file());
    break;
  }
}

void ax_select_menu_extra(char* target) {
  AXUIElementRef item = ax_get_extra_menu_item(target);
  if (!item) return;
  open_with_hidden_menu_bar(item, NULL);
  CFRelease(item);
}

extern void _SLPSGetFrontProcess(ProcessSerialNumber* psn);
extern void SLSGetConnectionIDForPSN(int cid, ProcessSerialNumber* psn, int* cid_out);
extern void SLSConnectionGetPID(int cid, pid_t* pid_out);
AXUIElementRef ax_get_front_app() {
  ProcessSerialNumber psn;
  _SLPSGetFrontProcess(&psn);
  int target_cid;
  SLSGetConnectionIDForPSN(SLSMainConnectionID(), &psn, &target_cid);

  pid_t pid;
  SLSConnectionGetPID(target_cid, &pid);
  return AXUIElementCreateApplication(pid);
}

int main (int argc, char **argv) {
  if (argc == 1) {
    printf("Usage: %s [-l | -e | -s id/alias | -c command ]\n", argv[0]);
    printf("  -l          list the front app's menus\n");
    printf("  -e          list menu bar icons, with the name to pass to -s\n");
    printf("  -s id       open the front app's menu at index id\n");
    printf("  -s alias    open a menu bar icon (com.apple.menuextra.wifi, AlDente, ...)\n");
    printf("  -c command  run a command that opens a menu (e.g. an app's CLI), hiding the menu bar the same way\n");
    exit(0);
  }
  ax_init();
  if (strcmp(argv[1], "-l") == 0) {
    AXUIElementRef app = ax_get_front_app();
    if (!app) return 1;
    ax_print_menu_options(app);
    CFRelease(app);
  } else if (strcmp(argv[1], "-e") == 0) {
    ax_print_menu_extras();
  } else if (argc == 3 && strcmp(argv[1], "-c") == 0) {
    open_with_hidden_menu_bar(NULL, argv[2]);
  } else if (argc == 3 && strcmp(argv[1], "-s") == 0) {
    int id = 0;
    if (sscanf(argv[2], "%d", &id) == 1) {
      AXUIElementRef app = ax_get_front_app();
      if (!app) return 1;
      ax_select_menu_option(app, id);
      CFRelease(app);
    } else ax_select_menu_extra(argv[2]);
  }
  return 0;
}
