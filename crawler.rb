require 'mechanize'


USERNAME = ARGV[0]
PASSWORD = ARGV[1]
URL_LOGIN = "https://extra2.bsgi.org.br/login/"
URL_RESERVA = "https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61#top"

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

  def login 
    page = @agent.get URL_LOGIN
    form = page.forms.first

    username_field = form.field_with(:name => 'codigo')
    username_field.value = USERNAME
    password_field = form.field_with(:name => 'senha')
    password_field.value = PASSWORD

    button = form.buttons.first
    page = form.submit button
  end

  def reserva
    page = @agent.get URL_RESERVA
    form = page.forms.first
    form.field_with(:name => 'data').value = '20/12/2017'
    form.field_with(:name => 'atividade').value = 'Ensaio dos eufônios'
    form.field_with(:name => 'organizacao').value = 'Núcleo Sul'
    form.field_with(:name => 'previsao').value = '20'
    form.field_with(:name => 'sala').value = '67' #VETERANOS
    form.field_with(:name => 'inicio').value = '19:00:00'
    form.field_with(:name => 'fim').value = '20:00:00'
    form.field_with(:name => 'divisao').value = '13' #GH - ENSAIO
    button = form.buttons.first
    page = form.submit button
    puts page.inspect
  end
end

crawler = Crawler.new
crawler.login
crawler.reserva




