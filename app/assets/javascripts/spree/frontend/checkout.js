var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : sParameterName[1];
        }
    }
};

var ready;
ready = function() {
  $("#add-to-cart-button").html('Comprar');

  var stock_error = getUrlParameter('enough-stock');
  if (stock_error == 'false') {
    alert('Lo lamento, ¡No tenemos suficiente stock!');
  };

  $("#add-to-cart-button").on("click", function(e) {

    e.preventDefault();
    var sku;
    var cantidad;
    var productTitle;

    productTitle = $('.product-title').html();
    cantidad = $('#quantity').val();
    url = window.location;

    if (productTitle == 'Cereal Avena') {
      sku = 12;
    } else if (productTitle == 'Cuero') {
      sku = 32;
    } else if (productTitle == 'Algodon') {
      sku = 21;
    } else if (productTitle == 'Huevo') {
      sku = 2;
    } else if (productTitle == 'Tela de lino') {
      sku = 28;
    }

    window.location = "http://integra2.ing.puc.cl/handle_payment?sku=" + sku + "&cantidad=" + cantidad + "&url=" + url;
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
