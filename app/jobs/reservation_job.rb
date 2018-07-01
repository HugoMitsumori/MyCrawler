class ReservationJob < ApplicationJob
  queue_as :reservations

  URL = 'https://extra2.bsgi.org.br/sedes_novo/reserva_sala/?id=61'

  def perform
    require 'capybara/poltergeist'
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, { js_errors: false })
    end
    Capybara.javascript_driver = :poltergeist
    Capybara.ignore_hidden_elements = false
    page = Capybara::Session.new(:poltergeist)
    page.visit URL
    login(page, '', '') unless page.first('.login100-form').nil?
    puts page.html
    reserve(page, Reservation.first)
  end

  private

  def login(page, user_code, password)
    page.fill_in 'id_codigo', with: user_code
    page.fill_in 'id_senha', with: password
    page.first('.login100-form-btn').trigger('click')
    sleep 5
  end

  def reserve(page, reservation)
    page.fill_in 'id_data', with: reservation.datetime.strftime('%d/%m/%Y')
    page.fill_in 'id_atividade', with: reservation.name
    page.fill_in 'id_organizacao', with: reservation.organization
    page.fill_in 'id_previsao', with: reservation.members

    page.select reservation.room, from: 'id_sala'
    page.select reservation.datetime.strftime('%H:%M'), from: 'id_inicio'
    page.select reservation.finish_time.strftime('%H:%M'), from: 'id_fim'
    page.select reservation.division, from: 'id_divisao'

    page.find('form').first('.btn-primary').trigger('click')
    sleep 2
    reservation.update(status: 'reservado') if page.find('.well').text == 'Reserva efetuada com sucesso!'
  end
end
