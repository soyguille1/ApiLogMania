require 'sinatra'
require 'json'
require 'sqlite3'

bd = SQLite3::Database.new('logs.db')

bd.execute <<-SQL
  CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY,
    marca_tiempo DATETIME,
    nivel TEXT,
    mensaje TEXT,
    id_servicio INTEGER
  );
SQL

post '/logs' do
  content_type :json

  begin
    entrada_log = JSON.parse(request.body.read)
    puts "Log recibido: #{entrada_log}"

    unless entrada_log_valida?(entrada_log)
      status 400
      return { error: 'Formato de entrada de log inválido' }.to_json
    end

    bd.execute("INSERT INTO logs (marca_tiempo, nivel, mensaje, id_servicio) 
                VALUES (?, ?, ?, ?)", 
                [entrada_log['marca_tiempo'], entrada_log['nivel'], entrada_log['mensaje'], entrada_log['id_servicio']])

    status 200
    { status: 'Log recibido' }.to_json
  rescue JSON::ParserError => e
    status 400
    { error: 'JSON inválido' }.to_json
  end
end

def entrada_log_valida?(entrada_log)
  entrada_log.key?('marca_tiempo') && entrada_log.key?('nivel') &&
  entrada_log.key?('mensaje') && entrada_log.key?('id_servicio')
end
