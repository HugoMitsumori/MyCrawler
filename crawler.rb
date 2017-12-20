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
    puts form.inspect
  end
end

crawler = Crawler.new
crawler.login
crawler.reserva




