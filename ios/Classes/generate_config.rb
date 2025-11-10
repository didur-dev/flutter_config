#!/usr/bin/env ruby

puts "--- [FlutterConfig] Início do Script ---"

# --- Lógica de Leitura de .env ---
def parse_dotenv(file_path); vars = {}; File.foreach(file_path) do |line|; next if line.strip.start_with?('#') || line.strip.empty?; if (matches = line.match(/^\s*(?:export\s+)?([\w\d\.\-_]+)\s*=\s*(.*)?\s*$/)); key = matches[1]; value = matches[2] ? matches[2].strip.sub(/^(['"])(.*)\1$/, '\2') : ''; vars[key] = value; end; end; vars; end

# --- CORREÇÃO: Usar PODS_PROJECT_ROOT para encontrar a pasta /ios e então voltar para a raiz do projeto Flutter ---
# PODS_PROJECT_ROOT nos dá o caminho para a pasta `ios`.
# Subir um nível (`..`) nos leva para a raiz do projeto Flutter, onde estão os arquivos .env.
project_root = File.join(ENV['SRCROOT'], '..', '..')

build_config = ENV['CONFIGURATION']
puts "[FlutterConfig] Raiz do projeto Flutter: #{project_root}"
puts "[FlutterConfig] Configuração de Build: #{build_config}"

# --- Lógica de Detecção de Flavor (sem alterações) ---
flavor = build_config&.include?('-') ? build_config.split('-').last.downcase : nil
puts "[FlutterConfig] Flavor extraído: #{flavor || 'Nenhum'}"
filename = ".env"
if flavor
  flavored_filename = ".env.#{flavor}"
  flavored_path = File.join(project_root, flavored_filename)
  puts "[FlutterConfig] Procurando pelo arquivo de flavor em: #{flavored_path}"
  if File.exist?(flavored_path)
    filename = flavored_filename
    puts "[FlutterConfig] SUCESSO: Arquivo de flavor encontrado!"
  else
    puts "[FlutterConfig] AVISO: Arquivo de flavor não encontrado. Usando '.env' como fallback."
  end
end

file_path = File.join(project_root, filename)
puts "[FlutterConfig] Caminho final do arquivo a ser lido: #{file_path}"
puts "[FlutterConfig] O arquivo existe? #{File.exist?(file_path)}"
unless File.exist?(file_path); puts "[FlutterConfig] ERRO: O arquivo final não foi encontrado."; exit 0; end
config_vars = parse_dotenv(file_path)
puts "[FlutterConfig] Variáveis carregadas: #{config_vars.keys.join(', ')}"

# --- Geração do Arquivo (sem alterações) ---
output_path = File.join(ENV['PODS_TARGET_SRCROOT'], 'Classes', 'FlutterConfigPlugin.m')
# ... (o resto do script permanece exatamente o mesmo) ...
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

puts "--- [FlutterConfig] Fim do Script ---"
