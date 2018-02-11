module CrawlerHelper
  URL = 'https://extra2.bsgi.org.br'.freeze
  URL_LOGIN =  'https://extra2.bsgi.org.br/login/'.freeze
  URL_CCSUL = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61#top'.freeze
  URL_INTERLAGOS = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=22#top'.freeze

  CCSUL_ROOMS = {
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
  }.freeze

  SALAS_INTERLAGOS = {
    'BUTSUMAN I' => '90',
    'BUTSUMAN II' => '88',
    'BUTSUMAN III' => '89',
    'BUTSUMAN IV' => '91',
    'SALA DE CONFERENCIA' => '92'
  }.freeze

  CAPACIDADE_CCSUL = {
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
  }.freeze

  CAPACIDADE_INTERLAGOS = {
    '90' => '150',
    '88' => '250',
    '89' => '50',
    '91' => '25',
    '92' => '20'
  }.freeze

  AllowedCodes = ['84242']

  def login(codigo, senha)
    @agent = agent

    page = @agent.get URL_LOGIN
    form = page.forms.first

    username_field = form.field_with(name: 'codigo')
    username_field.value = codigo
    password_field = form.field_with(name: 'senha')
    password_field.value = senha

    button = form.buttons.first
    page = form.submit button
    if page.title != '.:: BSGI Extranet ::.'
      return @agent
    else return false
    end
  end

  def reservar (sede, atividade, sala, data, inicio, fim, _previsao)
    url_reserva = sede == 'CCSUL' ? URL_CCSUL : URL_INTERLAGOS
    capacidade = sede == 'CCSUL' ? CAPACIDADE_CCSUL : CAPACIDADE_INTERLAGOS
    page = @agent.get url_reserva
    form = page.forms.first
    form.field_with(name: 'data').value = data
    form.field_with(name: 'atividade').value = atividade
    form.field_with(name: 'organizacao').value = 'Núcleo Sul'
    form.field_with(name: 'previsao').value = (Integer(capacidade[sala]) > 50 ? 50.to_s : capacidade[sala])
    form.field_with(name: 'sala').value = sala
    form.field_with(name: 'inicio').value = inicio
    form.field_with(name: 'fim').value = fim
    form.field_with(name: 'divisao').value = '13' # 13 = GH - ENSAIO
    button = form.buttons.first
    form.submit button
  end

  def extract_text(url)
    page = @agent.get url
    content = page.search("//div[@id='conteudo']")
    content.search("//div[@id='intro']").remove
    content.search("//div[@id='notas']").remove
    content.search("//div[@class='ui icon large teal message']").remove
    content[0]
  end

  def extract_article(url)
    page = @agent.get url
    header = page.search("//h1[@class='ui header']")
    subtitle = header.search("//div[@class='sub header']").remove
    subtitle.search('//img').remove
    subtitle[0].inner_html = '<i>' + subtitle[0].inner_html + '</i>'
    content = extract_text url
    return '' if content.nil?

    header << subtitle[0] unless subtitle[0].nil?

    header << content
    header
  end

  def schedule_reserve(date)
    script = File.new("#{date}.bat", '+w')
    dir = Dir.pwd
    script.puts "cd #{dir}"
    script.puts "ruby reservas.rb #{date}.scrt"

    script.close
    system "SchTasks /Create /SC ONCE /SD 24/12/2017 /ST 13:44 /TN \"#{date}Schedule\" /TR \"#{dir}\\#{date}.bat\""
  end

  private

  def agent
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
