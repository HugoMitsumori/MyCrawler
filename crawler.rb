require 'mechanize'
require 'highline/import'

URL_LOGIN = "https://extra2.bsgi.org.br/login/"
URL_RESERVA = "https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61#top"
SALAS = {
  'BIBLIOTECA' => '334',
  'REDE DA AMIZADE' => '66',
  'VETERANOS' => '67',
  'DIFUSÃO DA PAZ' => '68',
  'COZINHA' => '69',
  'EDUCACIONAL' => '70',
  'SAGUÃO SUPERIOR' => '71',
  'HARMONIA' => '72',
  'SOL DA ESPERANÇA' => '73',
  'VISITAS' => '75',
  'PILAR' => '76',
}

CAPACIDADE = {
  '334' => '20',
  '66' => '100',
  '67' => '60',
  '68' => '40',
  '69' => '10',
  '70' => '50',
  '71' => '100',
  '72' => '30',
  '73' => '30',
  '75' => '10',
  '76' => '10',
}

class Crawler
  def initialize
    @agent = Mechanize.new
    @agent.follow_meta_refresh = true
    @agent.redirect_ok = true
    @agent.keep_alive = true
    @agent.open_timeout = 30
    @agent.read_timeout = 30
    @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def login (codigo, senha)
    page = @agent.get URL_LOGIN
    form = page.forms.first

    username_field = form.field_with(:name => 'codigo')
    username_field.value = codigo
    password_field = form.field_with(:name => 'senha')
    password_field.value = senha

    button = form.buttons.first
    page = form.submit button
    if page.title != ".:: BSGI Extranet ::." then
      return true
    else return false
    end
  end

  def reservar (atividade, sala, data, inicio, fim)
    page = @agent.get URL_RESERVA
    form = page.forms.first
    form.field_with(:name => 'data').value = data
    form.field_with(:name => 'atividade').value = atividade
    form.field_with(:name => 'organizacao').value = 'Núcleo Sul'
    form.field_with(:name => 'previsao').value = (Integer(CAPACIDADE[sala]) > 50 ? 50.to_s : CAPACIDADE[sala])
    form.field_with(:name => 'sala').value = sala
    form.field_with(:name => 'inicio').value = inicio
    form.field_with(:name => 'fim').value = fim
    form.field_with(:name => 'divisao').value = '13' #GH - ENSAIO
    button = form.buttons.first
    #puts form.inspect
    page = form.submit button
    #puts page.inspect
  end
end

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





