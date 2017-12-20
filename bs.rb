load 'crawler.rb'

crawler = Crawler.new

crawler.login ARGV[0], ARGV[1]


crawler.extract_text "https://extra2.bsgi.org.br/impressos/online/ler/127035/"