# SerieExtractor.new(code, password, file_name).generate_html

# <initial_page> <final_page>
# <initial_edition> <final_edition>
# <chapter_names>
# ...

class SerieExtractor
  URL_NRH = "https://extra2.bsgi.org.br/impressos/online/serie/nova-revolucao-humana/"
  SUBSTITUTIONS = {
    "Nitiren" => "Nichiren",
    "utra de Lótus" => "utra do Lótus",
    "rengue" => "renge",
    "chakubuku" => "Shakubuku",
    "Chakubuku" => "Shakubuku",
    "odhisattva" => "odisatva",
    "ossen-rufu" => "osen-rufu",
    "akyamuni" => "hakyamuni",
    "Jossei" => "Josei",
    "Tsunessaburo" => "Tsunesaburo",
    "Makiguti" => "Makiguchi",
    "Shin-iti" => "Shin'ichi"
  }

  def initialize (code, password, file_name)
    @crawler = Crawler.instance
    @crawler.login code, password
    @initial_page
    @final_page
    @initial_edition
    @final_edition
    @current_part = 0
    @chapters = []
    @chapter_first_editions = []
    @current_chapter = ''
    @file = File.new(file_name + '.html', 'w+')
    @content = {}
    read_parameters "#{file_name}.txt"
  end

  def generate_html
    @file.puts "<!DOCTYPE html>\n<html>\n<body>\n<meta charset=\"utf-8\" />"
    @file.puts "<i>Brasil Seikyo, Edições #{@initial_edition} a #{@final_edition}</i>\n"

    for i in @final_page.downto @initial_page
      puts "= Acessando página #{URL_NRH + i.to_s}"
      @crawler.agent.visit(URL_NRH + i.to_s)
      page = @crawler.agent
      page = Nokogiri::HTML(page.html).search("//div[@class='content']").remove
      page.delete page.first

      page.reverse_each do |edition|
        process_edition edition
      end
    end
    @content.each do |key, chapter|
      @file.puts "<h1>#{key}</h1>\n"
      chapter.each_with_index do |part, index|
        if !part.nil?
          puts "#{key} #{index}"
          @file.puts part
        end
      end
    end

    @file.puts "</body>\n</html>"
    @file.close
  end

  private

  def read_parameters(file_name)
    file = File.new(file_name, 'r')
    @initial_page, @final_page = file.gets.split.map { |x| Integer(x) }
    @initial_edition, @final_edition = file.gets.split.map { |x| Integer(x) }
    while (chapter = file.gets)
      chapter = chapter.delete("\n").upcase
      chapter_name = chapter.split(' ', 2).last
      @chapters << chapter_name
      @chapter_first_editions << chapter.split.first.to_i
      @content[chapter_name] = []
    end
  end

  def process_edition (edition)
    edition_title = edition.content.gsub('  ', '').gsub(/[\n]+/, "\n").lines[1]
    edition_number = edition_title.split[1].to_i
    return unless edition_number.between?(@initial_edition, @final_edition)

    edition.children[3].children.each do |part|
      next if part.class == Nokogiri::XML::Text || part.text.strip.upcase == 'CAPA'
      # eliminates empty nodes

      link = part[:href]
      part_name = part.attribute_nodes[3].value.upcase
      temp_part_number = part_name.scan(/[\(][0-9]+[\)]/)[0]&.delete('()')
      if temp_part_number
        part_number = temp_part_number.to_i
      else
        part_number = edition.search('.header.blue')[0]&.text.strip.split[1].to_i
      end

      # when more than one part page per edition
      # @chapters.each do |chapter|
      #   unless part_name.include?(chapter)
      #     next
      #   end
      #   if @current_chapter != chapter
      #     @current_chapter = chapter
      #     puts "=====Novo capítulo: #{@current_chapter}====="
      #     @current_part = 1
      #   end
      #   part_url = Crawler::BASE_URL + link
      #   puts "processando #{part_name} de #{part_url}"
      #   @crawler.agent.visit part_url
      #   content = substitute_words(ArticlesExtractor.extract_text(@crawler.agent).to_s)
      #   @content[chapter][part_number] = content
      # end


      # check if new chapter
      if @chapter_first_editions.include? edition_number
        @current_chapter = @chapters[@chapter_first_editions.index(edition_number)]
        puts "=====Novo capítulo: #{@current_chapter}====="
        @current_part = 1
      end

      part_url = Crawler::BASE_URL + link
      puts "processando #{part_name} de #{part_url}"
      @crawler.agent.visit part_url
      content = substitute_words(ArticlesExtractor.extract_text(@crawler.agent).to_s)
      @content[@current_chapter][part_number] = content
    end
  end

  def substitute_words(content)
    SUBSTITUTIONS.each do |old_writting, new_writting|
      content = content.gsub(old_writting, new_writting)
    end
    content
  end
end