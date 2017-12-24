load 'crawler.rb'
require 'unicode'

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



class NRH
  def initialize (codigo, senha, file_name)
    @crawler = Crawler.new
    @crawler.login codigo, senha
    @initial_page
    @final_page
    @initial_edition
    @final_edition
    @current_part = 0
    @chapters = []
    @current_chapter = ""
    @file = File.new(file_name + ".html", "w+")
    @content = {}
    read_parameters file_name
  end

  def generate_html
    @file.puts "<!DOCTYPE html>\n<html>\n<body>\n<meta charset=\"utf-8\" />"
    @file.puts "<i>Brasil Seikyo, Edições #{@initial_edition} a #{@final_edition}</i>\n"

    for i in @final_page.downto @initial_page
      puts "= Processando #{URL_NRH + i.to_s}"
      page = @crawler.agent.get URL_NRH + i.to_s
      page = page.search("//div[@class='content']").remove
      page.delete page.first
    
      page.reverse_each do |edition|
        process_edition edition
      end
    end
    @content.each do |key, chapter|
      @file.puts "<h1>#{key}</h1>\n"
      chapter.each_with_index do |part, index|
        if part != nil
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
    file = File.new(file_name, "r")
    @initial_page, @final_page = file.gets.split.map{|x| Integer(x)}
    @initial_edition, @final_edition = file.gets.split.map{|x| Integer(x)}
    while ( chapter = file.gets)
      chapter = Unicode.upcase(chapter.gsub("\n",""))
      @chapters << chapter
      @content[chapter] = []
    end
  end

  def process_edition (edition)
    edition_title = edition.content.gsub("  ", "").gsub(/[\n]+/, "\n").lines[1]
    edition_number = Integer(edition_title.split[1])
    if edition_number.between?(@initial_edition, @final_edition)
      edition.children[3].children.each do |part|
        if part.class == Nokogiri::XML::Text 
          #eliminates empty nodes
          next 
        end

        link = part.attribute_nodes[1].value
        part_name = Unicode.upcase(part.attribute_nodes[3].value)
        part_number = Integer part_name.scan(/[\(][0-9]+[\)]/)[0].gsub("(", "").gsub(")", "")

        @chapters.each do |chapter|
          if part_name.include? chapter
            if @current_chapter != chapter 
              @current_chapter = chapter              
              puts "=====Novo capítulo: #{@current_chapter}====="
              @current_part = 1
            end
            puts "processando #{part_name} de #{(URL + link)}"
            content = substitute_words(@crawler.extract_text(URL + link).to_s)
            @content[chapter][part_number] = content
          end
        end        
      end                  
    end
  end

  def substitute_words (content)
    SUBSTITUTIONS.each do |old_writting, new_writting|
      content = content.gsub(old_writting, new_writting)
    end
    return content
  end
end

nrh = NRH.new ARGV[0], ARGV[1], ARGV[2]
nrh.generate_html










