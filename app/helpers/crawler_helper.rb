# provides data and useful methods
module CrawlerHelper
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
    'PILAR' => '76'
  }.freeze

  SALAS_INTERLAGOS = {
    'BUTSUMAN I' => '90',
    'BUTSUMAN II' => '88',
    'BUTSUMAN III' => '89',
    'BUTSUMAN IV' => '91',
    'SALA DE CONFERENCIA' => '92'
  }.freeze

  ALLOWED_CODES = %w[84242 165559 183366].freeze

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

  def schedule_reservation(date)
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
