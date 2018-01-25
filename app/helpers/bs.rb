load 'crawler.rb'

URL_BS = 'https://extra2.bsgi.org.br/impressos/online/edicao/bs/'

crawler = Crawler.new

crawler.login ARGV[0], ARGV[1]

page = crawler.agent.get URL_BS
links = []
content = page.search("//div[@class='ui big list']")
content.search('//a[@class="item color-grey"]').map { |link| links << link['href'] }


output = File.new 'saida.html', 'w+'
output.puts "<!DOCTYPE html>\n<html>\n<body>\n<meta charset=\"utf-8\" />"

content = page.search('//h2')
output.puts content

links.each do |link|
  content = crawler.extract_article URL + link
  output.puts content
end
output.puts "</body>\n</html>"
output.close