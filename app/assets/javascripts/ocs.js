$(document).ready(function(){
  var options = {
    valueNames: [ 'idoc', 'idfactura', 'estado', 'fechaRecepcion', 'fechaEntrega', 'canal', 'cliente', 'proveedor', 'sku', 'cantidad', 'cantidadDespachada' ]
  };

  var ocList = new List('ocs', options);
});
