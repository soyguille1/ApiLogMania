require 'net/http'
require 'json'
require 'logger'
require 'sqlite3'

bd = SQLite3::Database.new('logs.db')

registro = Logger.new(STDOUT)

niveles_registro = {
  debug: Logger::DEBUG,
  info: Logger::INFO,
  warning: Logger::WARN,
  error: Logger::ERROR,
  fatal: Logger::FATAL
}

def enviar_log(entrada_log)
  uri = URI('http://localhost:4567/logs')
  http = Net::HTTP.new(uri.host, uri.port)
  solicitud = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  solicitud.body = entrada_log.to_json

  respuesta = http.request(solicitud)
  puts "Respuesta del servidor: #{respuesta.body}"
end

niveles_registro.each do |nivel, severidad|
  entrada_log = {
    marca_tiempo: Time.now.to_s,
    nivel: nivel.to_s,
    mensaje: "Mensaje de #{nivel.capitalize}",
    id_servicio: 1
  }

  registro.add(severidad) { entrada_log[:mensaje] }

  enviar_log(entrada_log)

  bd.execute("INSERT INTO logs (marca_tiempo, nivel, mensaje, id_servicio) 
              VALUES (?, ?, ?, ?)", 
              [entrada_log[:marca_tiempo], entrada_log[:nivel], entrada_log[:mensaje], entrada_log[:id_servicio]])
end
