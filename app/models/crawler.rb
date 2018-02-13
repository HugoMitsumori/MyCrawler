# Crawler
class Crawler
  include ActiveModel::Model
  include Singleton
  attr_accessor :code, :password
  attr_writer :agent

  BASE_URL = 'https://extra2.bsgi.org.br'.freeze
  CENTER_RESERVATION_URL = '/sedes_novo/reserva_sala/?id='.freeze
  ROOMS_CAPACITY_URL = '/sedes_novo/salas/?id='.freeze
  URL_LOGIN = 'https://extra2.bsgi.org.br/login/'.freeze
  URL_CCSUL = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61#top'.freeze
  URL_INTERLAGOS = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=22#top'.freeze

  CENTER_CODES = {
    'CCSUL': '61',
    'INTERLAGOS': '22'
  }.freeze

  CAPACIDADE_CCSUL = {
    '334' => 20,
    '66' => 100,
    '67' => 60,
    '68' => 40,
    '69' => 10,
    '70' => 50,
    '71' => 100,
    '72' => 30,
    '73' => 30,
    '75' => 10,
    '76' => 10
  }.freeze

  CAPACIDADE_INTERLAGOS = {
    '90' => 150,
    '88' => 250,
    '89' => 50,
    '91' => 25,
    '92' => 20
  }.freeze

  def login(code, password)
    page = agent.get URL_LOGIN
    form = page.forms.first

    username_field = form.field_with(name: 'codigo')
    username_field.value = code
    password_field = form.field_with(name: 'senha')
    password_field.value = password
    @code = code
    @password = password

    button = form.buttons.first
    page = form.submit button
    return false if page.title == '.:: BSGI Extranet ::.'
    agent.cookie_jar.save('cookies.yml', session: true)
    agent
  end

  def ensure_logged_in
    if File.exist?('cookies.yml')
      agent.cookie_jar.load('cookies.yml')
    elsif agent.nil?
      login(@code, @password)
    end
  end

  def reserve(sede, sala, reservation)
    ensure_logged_in
    url_reserva = sede == 'CCSUL' ? URL_CCSUL : URL_INTERLAGOS
    capacidade = sede == 'CCSUL' ? CAPACIDADE_CCSUL : CAPACIDADE_INTERLAGOS
    previsao = capacidade[sala] > reservation.members ? reservation.members.to_s : capacidade[sala].to_s
    page = agent.get url_reserva
    form = page.forms.first
    form.field_with(name: 'data').value = reservation.date
    form.field_with(name: 'atividade').value = reservation.name
    form.field_with(name: 'organizacao').value = reservation.organization
    form.field_with(name: 'previsao').value = previsao
    form.field_with(name: 'sala').value = sala
    form.field_with(name: 'inicio').value = reservation.start_time
    form.field_with(name: 'fim').value = reservation.finish_time
    form.field_with(name: 'divisao').value = reservation.division # 13 = GH - ENSAIO, 1 = 5D
    button = form.buttons.first
    puts 'APERTANDO BOTÃO' + button.inspect
    form.submit button
  end

  # gets rooms capacity for given center
  def capacity(center_name)
    ensure_logged_in
    url = BASE_URL + ROOMS_CAPACITY_URL + CENTER_CODES[center_name.to_sym]
    rooms_capacity = {}
    page = agent.get url
    page.css('tbody').css('tr').each_with_index do |tr, i|
      next if i.odd?
      room = tr.css('h6').text
      capacity = tr.css('td')[1].text
      rooms_capacity[room] = capacity
    end
    rooms_capacity
  end

  def agent
    @agent = new_agent if @agent.nil?
    @agent
  end

  private

  def new_agent
    agent = Mechanize.new
    agent.follow_meta_refresh = true
    agent.redirect_ok = true
    agent.keep_alive = true
    agent.open_timeout = 30
    agent.read_timeout = 30
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    agent
  end
end
