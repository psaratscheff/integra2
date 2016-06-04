var ready;
ready = function() {
  $("#add-to-cart-button").html('Comprar');

  $("#add-to-cart-button").on("click", function(e) {

    e.preventDefault();
    var sku;
    var cantidad;
    var productTitle;

    productTitle = $('.product-title').html();
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
    cantidad = $('#quantity').val();

    window.location = "http://localhost:3000/handle_payment?sku=" + sku + "&cantidad=" + cantidad;
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
