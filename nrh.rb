load 'crawler.rb'

URL_NRH = "https://extra2.bsgi.org.br/impressos/online/serie/nova-revolucao-humana/"

crawler = Crawler.new

crawler.login ARGV[0], ARGV[1]

initial_page = ARGV[2]
final_page = ARGV[3]
initial_edition = ARGV[4]
final_edition = ARGV[5]

current_chapter = ""


# for i in Integer(final_page).downto Integer(initial_page)
# 	page = crawler.agent.get URL_NRH + i.to_s
# 	puts page.inspect
# end

page = crawler.agent.get URL_NRH + final_page
page = page.search("//div[@class='content']").remove
page.delete page.first

j = 0
page.each do |edition|
	edition_title = edition.content.gsub("  ", "").gsub(/[\n]+/, "\n").lines[1]
	
end





