#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_config'
  s.version          = '3.0.0'
  s.summary          = 'Config Variables for your Flutter Apps.'
  s.description      = 'Automatically detects build flavors on iOS without manual setup.'
  s.homepage         = 'https://github.com/ByneappLLC/flutter_config'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Byne App' => 'engineering@byneapp.com' }
  s.source           = { :path => '.' }
  s.dependency       = 'Flutter'
  s.platform         = :ios, '11.0'

  s.source_files = 'Classes/FlutterConfigPlugin.h', 'Classes/FlutterConfigPlugin.m'
  s.public_header_files = 'Classes/FlutterConfigPlugin.h'
  
  s.script_phase = {
    :name => '[FlutterConfig] Generate Config',
    :script => '"${PODS_TARGET_SRCROOT}/Classes/generate_config.rb"',
    :execution_position => :before_compile,
    :input_files => ['${SRCROOT}/../../.env', '${SRCROOT}/../../.env.*'],
    :output_files => ['${PODS_TARGET_SRCROOT}/Classes/FlutterConfigPlugin.m']
  }
end
