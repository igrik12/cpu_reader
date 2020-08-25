#import "CpuReaderPlugin.h"
#if __has_include(<cpu_reader/cpu_reader-Swift.h>)
#import <cpu_reader/cpu_reader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cpu_reader-Swift.h"
#endif

@implementation CpuReaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCpuReaderPlugin registerWithRegistrar:registrar];
}
@end
