Rails.application.routes.draw do

  get 'dashboard/index'
  get 'dashboard/bodega'
  get 'dashboard/productos'
  get 'dashboard/materiasprimas'
  get 'dashboard/saldobanco'

  get 'dashboard/recepcion'
  get 'dashboard/despacho'
  get 'dashboard/almacen1'
  get 'dashboard/almacen2'
  get 'dashboard/pulmon'

  get 'dashboard/trx'
  
  get 'dashboard/ventas'

  get 'dashboard/ingresos'

  resources :pagos
  resources :pagos
  resources :facturas
  resources :almacens
  
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/spree'
  get '/handle_payment', to: 'web#procesar_compra'
  get '/handle_payment/despachar_producto/264f93gfwygf7sdfyb/:id_boleta', to: 'web#success'

  resources :ocs, only: [:index, :show]
  resources :items, only: [:index, :show]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/welcome', to: 'welcome#index'

  # Estas rutas solo sirven para testear resulado en la terminal
  # => get 'sftp', to: 'api/oc#sftp'
  # => get 'hmactest', to: 'api/oc#hmactest'
  get 'scripts/analizar_sftp'

  get 'tasks/procesar_sftp'
  get 'tasks/producirMateriaPrima/:sku', to: 'tasks#producirMP'

  # utilizar el namespace, es lo mismo que agregar /api/ a la ruta:
  # => get 'api/documentacion', to: 'documentacion#index'
  namespace :api, defaults: { format: :json } do
    # We are going to list our resources here
    get 'documentacion', to: 'documentacion#index', defaults: { format: 'html' }
    get 'consultar/:sku', to: 'stock#consultar'
    get 'oc/recibir/:idoc', to: 'oc#recibir'
    get 'facturas/recibir/:idfactura', to: 'facturas#recibir'
    get 'ids/grupo'
    get 'ids/banco'
    get 'ids/almacenId'
    get 'pagos/recibir/:idtrx', to: 'pagos#recibir'
    get 'despachos/recibir/:idfactura', to: 'despachos#recibir'
  end

  # Tests:
  get '/verstock', to: 'scripts#verstock'
  get '/log', to: 'scripts#log'
  get '/test2t', to: 'scripts#test2t'
  get '/test2f', to: 'scripts#test2f'
  get '/test1', to: 'scripts#test1'
  get '/test3', to: 'scripts#test3'
  get '/test4', to: 'scripts#test4'
  get '/test5', to: 'scripts#test5'
  get '/test6', to: 'scripts#test6'
  get '/test7', to: 'scripts#test7'
  get '/test8', to: 'scripts#test8'
  get '/test9', to: 'scripts#test9'
  get '/test10', to: 'scripts#test10'
  get '/test11', to: 'scripts#test11'
  get '/test12', to: 'scripts#test12'
end

# Example of regular route:
#   get 'products/:id' => 'catalog#view'

# Example of named route that can be invoked with purchase_url(id: product.id)
#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

# Example resource route (maps HTTP verbs to controller actions automatically):
#   resources :products

# Example resource route with options:
#   resources :products do
#     member do
#       get 'short'
#       post 'toggle'
#     end
#
#     collection do
#       get 'sold'
#     end
#   end

# Example resource route with sub-resources:
#   resources :products do
#     resources :comments, :sales
#     resource :seller
#   end

# Example resource route with more complex sub-resources:
#   resources :products do
#     resources :comments
#     resources :sales do
#       get 'recent', on: :collection
#     end
#   end

# Example resource route with concerns:
#   concern :toggleable do
#     post 'toggle'
#   end
#   resources :posts, concerns: :toggleable
#   resources :photos, concerns: :toggleable

# Example resource route within a namespace:
#   namespace :admin do
#     # Directs /admin/products/* to Admin::ProductsController
#     # (app/controllers/admin/products_controller.rb)
#     resources :products
#   end
