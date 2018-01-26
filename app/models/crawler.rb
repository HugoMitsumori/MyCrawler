# Crawler
class Crawler
  include ActiveModel::Model
  include Singleton
  attr_accessor :agent, :code, :password

  URL_LOGIN =  'https://extra2.bsgi.org.br/login/'
  URL_CCSUL = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61#top'
  URL_INTERLAGOS = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=22#top'
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
  }

  CAPACIDADE_INTERLAGOS = {
    '90' => '150',
    '88' => '250',
    '89' => '50',
    '91' => '25',
    '92' => '20'
  }

  def login (codigo, senha)
    @agent = new_agent

    page = @agent.get URL_LOGIN
    form = page.forms.first

    username_field = form.field_with(name: 'codigo')
    username_field.value = codigo
    password_field = form.field_with(name: 'senha')
    password_field.value = senha

    button = form.buttons.first
    page = form.submit button
    if page.title != '.:: BSGI Extranet ::.' then  
      agent.cookie_jar.save("cookies.yaml", session: true)
      return @agent
    else return false
    end
  end

  def reserve (sede, atividade, sala, data, inicio, fim, previsao)
    if @agent.nil?
      if !login @code, @password        
        puts "ERRO PARA LOGAR com #{@code} e #{@password}"
        return
      end
    end
    url_reserva = sede == 'CCSUL' ? URL_CCSUL : URL_INTERLAGOS
    capacidade = sede == 'CCSUL' ? CAPACIDADE_CCSUL : CAPACIDADE_INTERLAGOS
    page = @agent.get url_reserva
    form = page.forms.first
    form.field_with(name: 'data').value = data
    form.field_with(name: 'atividade').value = atividade
    form.field_with(name: 'organizacao').value = 'Distrito Fachini'# 'Núcleo Sul'
    form.field_with(name: 'previsao').value = (Integer(capacidade[sala]) > Integer(previsao) ? previsao : capacidade[sala])
    form.field_with(name: 'sala').value = sala
    form.field_with(name: 'inicio').value = inicio
    form.field_with(name: 'fim').value = fim
    form.field_with(name: 'divisao').value = '1' #13 = GH - ENSAIO, 1 = 5D
    button = form.buttons.first
    page = form.submit button
  end

  private

  def new_agent
    agent = Mechanize.new
    agent.follow_meta_refresh = true
    agent.redirect_ok = true
    agent.keep_alive = true
    agent.open_timeout = 30
    agent.read_timeout = 30
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    return agent
  end
end
