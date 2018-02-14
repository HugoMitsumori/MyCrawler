# Crawler
class Crawler
  include ActiveModel::Model
  include Singleton
  attr_accessor :code, :password
  attr_writer :agent

  BASE_URL = 'https://extra2.bsgi.org.br'.freeze
  RESERVATION_URL = '/sedes_novo/reserva_sala/?id='.freeze
  ROOMS_CAPACITY_URL = '/sedes_novo/salas/?id='.freeze
  URL_LOGIN = 'https://extra2.bsgi.org.br/login/'.freeze

  CENTER_CODES = {
    'CCSUL': '61',
    'INTERLAGOS': '22'
  }.freeze

  def login(code, password)
    puts 'LOGGING IN'
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

  def reserve(room, reservation)
    ensure_logged_in
    center = reservation.center
    url_reservation = BASE_URL + RESERVATION_URL + CENTER_CODES[center.to_sym]
    room_capacity = capacity(center)[rooms(center)[room]]
    members = room_capacity > reservation.members ? reservation.members.to_s : room_capacity.to_s
    page = agent.get url_reservation
    form = page.forms.first
    form.field_with(name: 'data').value = reservation.date
    form.field_with(name: 'atividade').value = reservation.name
    form.field_with(name: 'organizacao').value = reservation.organization
    form.field_with(name: 'previsao').value = members
    form.field_with(name: 'sala').value = room
    form.field_with(name: 'inicio').value = reservation.start_time
    form.field_with(name: 'fim').value = reservation.finish_time
    form.field_with(name: 'divisao').value = reservation.division # 13 = GH - ENSAIO, 1 = 5D
    button = form.buttons.first
    form.submit button
  end

  # gets rooms capacity for given center
  def capacity(center_name)
    @rooms_capacity = {} if @rooms_capacity.nil?
    return @rooms_capacity[center_name] unless @rooms_capacity[center_name].nil?
    puts 'GETTING CAPACITY FROM SERVER'
    ensure_logged_in
    url = BASE_URL + ROOMS_CAPACITY_URL + CENTER_CODES[center_name.to_sym]
    rooms_capacity = {}
    page = agent.get url
    page.css('tbody').css('tr').each_with_index do |tr, i|
      next if i.odd?
      room = tr.css('h6').text
      capacity = tr.css('td')[1].text
      rooms_capacity[room] = Integer(capacity)
    end
    @rooms_capacity[center_name] = rooms_capacity unless rooms_capacity.empty?
    rooms_capacity
  end

  # gets rooms name and key
  def rooms(center_name)
    @rooms = {} if @rooms.nil?
    return @rooms[center_name] unless @rooms[center_name].nil? or @rooms[center_name].empty?
    puts 'GETTING ROOMS FROM SERVER'
    ensure_logged_in
    url = BASE_URL + RESERVATION_URL + CENTER_CODES[center_name.to_sym]
    center_rooms = {}
    page = agent.get url
    page.css('select#id_sala').css('option').each do |option|
      room_number = option['value']
      room_name = option.text
      center_rooms[room_number] = room_name
    end
    center_rooms.delete ''
    @rooms[center_name] = center_rooms
    center_rooms
  end

  def room_name(center, room_number)
    rooms(center)[room_number]
  end

  def reservations_page(center)
    ensure_logged_in
    url = BASE_URL + "/sedes_novo/mapa_atividades/?id=#{CENTER_CODES[center.to_sym]}"
    page = agent.get(url).css('div#myTabContent table')
    page.css('td.detalhe').remove
    page.css('td.aleft').remove
    page.css('em').remove
    page.xpath("//td[@class='bg_cinza atividade']").remove
    page.xpath("//span[@class='label label-success']").remove
    page.xpath('//tr[th]').remove
    page.xpath("//th[not(@colspan='6')]").remove
    page.xpath('//tr[not(thead) and not(td[nobr])]').remove
    page.xpath("//td[@rowspan='2']").remove
    page.to_s.gsub('  ', '').gsub(/[\n]+/, "\n").html_safe
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
