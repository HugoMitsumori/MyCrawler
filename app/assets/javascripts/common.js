$(document).on('turbolinks:load', function() {
  $('#login-form').on('submit', function() {
    $('#session-message').append('Entrando. Aguarde...');
  });

  var reserveProcessingMessage = function() {
    $('#reserve-message').empty();
    $('#reserve-message').append('Processando reservas. Aguarde...');
  };

  $('#reserve-form').on('submit', reserveProcessingMessage);
  $('#reserve-submit').on('click', reserveProcessingMessage);

  $('#fill-form').on('click', function() {
    $('#reserve_name').val('Ensaio do Taiyo Ongakutai');
    $('#reserve_organization').val('Núcleo Sul');
    $('#reserve_division').val('13');
    $('#reserve_members').val('50');
  });
});