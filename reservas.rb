load 'crawler.rb'

def get_data(prompt)
  ask(prompt)
end

def get_password(prompt='Password: ')
  ask(prompt) { |q| q.echo = false}
end

crawler = Crawler.new

if ARGV[0] == nil 

  loop do
    codigo = get_data "Digite seu codigo (sem o último digito): "
    senha = get_password "Digite sua senha: "
    break if crawler.login codigo, senha
    puts "Erro de autenticação!!"
  end

  atividade = get_data "Digite o nome padrão para a atividade: "

  data = get_data "Digite a data no formato dd/mm/aa: "

  hora = get_data "Digite o horário de inicio e fim (no formato 00:00:00 00:00:00) : "
  inicio, fim  = hora.split

  SALAS.each do |k, v|
    puts "#{k} - #{v}"
  end
  salas = get_data "Digite os codigos das salas separados por espaco: "
  salas = salas.split

  salas.each do |sala|
    crawler.reservar atividade, sala, data, inicio, fim
    sleep 2
  end
else
  parameters = File.new(ARGV[0], "r")
  codigo, senha = parameters.gets.split
  if crawler.login codigo, senha
  	sleep 10
    atividade = parameters.gets.gsub("\n", "")
    data = parameters.gets.gsub("\n", "")
    inicio, fim = parameters.gets.split
    salas = parameters.gets.split
    salas.each do |sala|
      crawler.reservar atividade, sala, data, inicio, fim
      sleep 5
    end
  end
  parameters.close
end