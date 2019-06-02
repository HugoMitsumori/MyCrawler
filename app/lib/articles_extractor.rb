URL_BS = 'https://extra2.bsgi.org.br/impressos/online/edicao/bs/'.freeze

class ArticlesExtractor
  def self.extract(code, password)
    crawler = Crawler.instance

    crawler.login code, password

    page = crawler.agent
    page.visit URL_BS
    links = []
    content = page.first('.ui.big.list')
    content.all('.item.color-grey').map { |link| links << link['href'] }

    output = File.new 'saida.html', 'w+'
    output.puts "<!DOCTYPE html>\n<html>\n<body>\n<meta charset=\"utf-8\" />"

    content = page.first('h2').text
    output.puts content

    links.each do |link|
      content = extract_article(page, link)
      output.puts content
    end
    output.puts "</body>\n</html>"
    output.close
  end

  def self.extract_article(page, url)
    page.visit url
    header = Nokogiri::HTML(page.html).search("//h1[@class='ui header']")
    subtitle = header.search("//div[@class='sub header']").remove
    subtitle.search('//img').remove
    subtitle[0].inner_html = '<i>' + subtitle[0].inner_html + '</i>'
    content = extract_text(page)
    return '' if content.nil?

    header << subtitle[0] unless subtitle[0].nil?

    header << content
    header
  end

  def self.extract_text(page)
    content = Nokogiri::HTML(page.html).search("//div[@id='conteudo']")
    content.search("//div[@id='intro']").remove
    content.search("//div[@id='notas']").remove
    content.search("//div[@class='ui icon large teal message']").remove
    content[0]
  end
end


