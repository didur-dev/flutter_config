#!/usr/bin/env ruby

# --- Funções e Lógica Principal ---
def parse_dotenv(file_path)
  vars = {}
  File.foreach(file_path) do |line|
    next if line.strip.start_with?('#') || line.strip.empty?
    if (matches = line.match(/^\s*(?:export\s+)?([\w\d\.\-_]+)\s*=\s*(.*)?\s*$/))
      key = matches[1]
      value = matches[2] ? matches[2].strip.sub(/^(['"])(.*)\1$/, '\2') : ''
      vars[key] = value
    end
  end
  vars
end

# A variável SRCROOT é garantida de existir e aponta para .../ios/Pods.
# Subimos dois níveis para chegar à raiz do projeto Flutter.
project_root = File.join(ENV['SRCROOT'], '..', '..')

build_config = ENV['CONFIGURATION']
flavor = build_config&.include?('-') ? build_config.split('-').last.downcase : nil

filename = ".env"
if flavor
  flavored_filename = ".env.#{flavor}"
  flavored_path = File.join(project_root, flavored_filename)
  if File.exist?(flavored_path)
    filename = flavored_filename
  end
end

file_path = File.join(project_root, filename)
unless File.exist?(file_path)
  exit 0
end

config_vars = parse_dotenv(file_path)

# --- Geração do Arquivo de Implementação ---
output_path = File.join(ENV['PODS_TARGET_SRCROOT'], 'Classes', 'FlutterConfigPlugin.m')

file_content = <<-M
// Gerado por flutter_config/generate_config.rb
#import "FlutterConfigPlugin.h"
@implementation FlutterConfigPlugin
+ (NSDictionary *)env {
    return @{
        #{config_vars.map { |k, v| "@\"#{k}\": @\"#{v.gsub('"', '\"')}\"" }.join(",\n        ")}
    };
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_config" binaryMessenger:[registrar messenger]];
    FlutterConfigPlugin* instance = [[FlutterConfigPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"loadEnvVariables" isEqualToString:call.method]) { result([FlutterConfigPlugin env]); }
    else { result(FlutterMethodNotImplemented); }
}
@end
M

File.write(output_path, file_content)