$(document).on('turbolinks:load', function() {
  $('#login-form').on('submit', function() {
    $('#session-message').text('Entrando. Aguarde...');
  });

  var reservationProcessingMessage = function() {
    $('#reservation-message').empty();
    $('#reservation-message').append('Processando reservas. Aguarde...');
  };

  $('#reservation-form').on('submit', reservationProcessingMessage);
  $('#reservation-submit').on('click', reservationProcessingMessage);

  $('#fill-form').on('click', function() {
    $('#reservation_name').val('Ensaio do Taiyo Ongakutai');
    $('#reservation_organization').val('Núcleo Sul');
    $('#reservation_division').val('GH - Ensaio');
    $('#reservation_members').val('50');
  });
});