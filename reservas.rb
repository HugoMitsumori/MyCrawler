load 'crawler.rb'

def get_data(prompt)
  ask(prompt)
end

def get_password(prompt='Password: ')
  ask(prompt) { |q| q.echo = false}
end

crawler = Crawler.new

loop do
  codigo = get_data "Digite seu codigo (sem o último digito): "
  senha = get_password "Digite sua senha: "
  break if crawler.login codigo, senha
  puts "Erro de autenticação!!"
end

atividade = get_data "Digite o nome padrão para a atividade: "

data = get_data "Digite a data no formato dd/mm/aa: "

hora = get_data "Digite o horário de inicio e fim (no formato 00:00:00 00:00:00) : "
inicio = hora.split[0]
fim = hora.split[1]

SALAS.each do |k, v|
  puts "#{k} - #{v}"
end
salas = get_data "Digite os codigos das salas separados por espaco: "
salas = salas.split

salas.each do |sala|
  crawler.reservar atividade, sala, data, inicio, fim
  sleep 2
end