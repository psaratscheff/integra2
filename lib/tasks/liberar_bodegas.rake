desc "Liberar Bodega recepcion"
task :liberar_bodega_recepcion do
  $ambiente = true
  if $ambiente
    url = "http://integra2.ing.puc.cl/tasks/limpiar_recepcion_background"
  else
    url = "http://localhost:3000/tasks/limpiar_recepcion_background"
  end
  HTTParty.get(url)
end
