#import "FlutterConfigPlugin.h"

// Este arquivo serve como um placeholder completo.
// O script de build irá sobrescrevê-lo com as variáveis reais.
// A presença deste arquivo durante o 'pod install' é crucial
// para evitar o MissingPluginException.

@implementation FlutterConfigPlugin
+ (NSDictionary *)env {
    return @{};
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_config"
                                     binaryMessenger:[registrar messenger]];
    FlutterConfigPlugin* instance = [[FlutterConfigPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"loadEnvVariables" isEqualToString:call.method]) {
        result([FlutterConfigPlugin env]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}
@end