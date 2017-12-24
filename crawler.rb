require 'mechanize'
require 'highline/import'

URL = "https://extra2.bsgi.org.br"
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
  attr_reader :agent

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
    page = form.submit button
    puts page.inspect
  end

  def extract_text (url)
    page = @agent.get url
    content = page.search("//div[@id='conteudo']")
    content.search("//div[@id='intro']").remove
    content.search("//div[@id='notas']").remove    
    content.search("//div[@class='ui icon large teal message']").remove
    return content[0]
  end

  def extract_article (url)
    page = @agent.get url
    header = page.search("//h1[@class='ui header']")
    subtitle = header.search("//div[@class='sub header']").remove
    subtitle.search("//img").remove
    subtitle[0].inner_html = "<i>" + subtitle[0].inner_html + "</i>"
    content = extract_text url
    if content == nil 
      return ""
    end
    if subtitle[0] != nil
      header << subtitle[0]
    end
    header << content
    return header
  end

  def schedule_reserve(date)
    script = File.new("#{date}.bat", "+w")
    dir = Dir.pwd
    script.puts "cd #{dir}"
    script.puts "ruby reservas.rb #{date}.scrt"

    script.close
    system "SchTasks /Create /SC ONCE /SD 24/12/2017 /ST 13:44 /TN \"#{date}Schedule\" /TR \"#{dir}\\#{date}.bat\""
  end
end







