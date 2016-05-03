Rails.application.routes.draw do

  resources :ocs, only: [:index, :show]
  resources :items, only: [:index, :show]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  #get 'welcome/index'

  # Estas rutas solo sirven para testear resulado en la terminal
  # => get 'sftp', to: 'api/oc#sftp'
  # => get 'hmactest', to: 'api/oc#hmactest'
  get 'scripts/analizar_sftp'
  get 'scripts/probar_compra'
  get 'scripts/test'
  get 'scripts/verstock'

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
  end
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
