// Adds folders to Spotlight's privacy exclusions (Settings > Spotlight > Search privacy), using the
// private Metadata.framework calls behind that pane. They go through mds, so no root or Full Disk
// Access is needed, unlike editing .Spotlight-V100. Never removes an exclusion.
//   spotlight-exclude <folder>...
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include <stdio.h>
#include <sys/stat.h>

int main(int argc, char **argv) {
  void *metadata = dlopen("/System/Library/Frameworks/CoreServices.framework/CoreServices", RTLD_LAZY);
  CFArrayRef (*copyExclusions)(void) = dlsym(metadata, "_MDCopyExclusionList");
  Boolean (*setExclusion)(CFStringRef, Boolean) = dlsym(metadata, "_MDSetExclusion");
  if (!copyExclusions || !setExclusion) {
    fprintf(stderr, "spotlight-exclude: Spotlight exclusion API not found\n");
    return 1;
  }

  CFArrayRef exclusions = copyExclusions();
  for (int i = 1; i < argc; i++) {
    struct stat info;
    if (stat(argv[i], &info) != 0 || !S_ISDIR(info.st_mode)) {
      fprintf(stderr, "spotlight-exclude: skipping %s, not a folder\n", argv[i]);
      continue;
    }
    CFStringRef path = CFStringCreateWithCString(NULL, argv[i], kCFStringEncodingUTF8);
    if (!exclusions || !CFArrayContainsValue(exclusions, CFRangeMake(0, CFArrayGetCount(exclusions)), path)) {
      setExclusion(path, true);
      printf("Excluded %s from Spotlight\n", argv[i]);
    }
    CFRelease(path);
  }
  return 0;
}
