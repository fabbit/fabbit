Fabbit::Application.routes.draw do
  root to: "home#home"

  match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"
  match "/model/:filename", to: "dropbox#display", filename: /.+/, as: "model"    #TODO Change!

  resources :dropbox, only: [ :new ]
end
