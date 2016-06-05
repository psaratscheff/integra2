var ready;
ready = function() {
  $('#despachado').html('¡Pedido despachado exitosamene!');
};

$(document).ready(ready);
$(document).on('page:load', ready);
