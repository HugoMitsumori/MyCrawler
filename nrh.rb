load 'crawler.rb'

URL_NRH = "https://extra2.bsgi.org.br/impressos/online/serie/nova-revolucao-humana/"

class NRH
  def initialize (codigo, senha, file_name)
    @crawler = Crawler.new
    @crawler.login codigo, senha
    @initial_page
    @final_page
    @initial_edition
    @final_edition
    @chapters = []
    read_parameters file_name
  end

  def generate_html

    # for i in Integer(final_page).downto Integer(initial_page)
    #   page = crawler.agent.get URL_NRH + i.to_s
    #   puts page.inspect
    # end
    page = @crawler.agent.get URL_NRH + @final_page.to_s
    page = page.search("//div[@class='content']").remove
    page.delete page.first

    page.reverse_each do |edition|
      process_edition edition
    end
  end

  private

  def read_parameters(file_name)
    file = File.new(file_name, "r")
    @initial_page, @final_page = file.gets.split.map{|x| Integer(x)}
    @initial_edition, @final_edition = file.gets.split.map{|x| Integer(x)}
    while ( chapter = file.gets)
      @chapters << chapter.gsub("\n","")
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
        part_name = part.attribute_nodes[3].value

        @chapters.each do |chapter|
          if part_name.include? chapter
            process_chapter
          end
        end        
      end                  
    end
  end

  def process_chapter
  end
end

nrh = NRH.new ARGV[0], ARGV[1], ARGV[2]
nrh.generate_html










