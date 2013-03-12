Fabbit::Application.routes.draw do
  root to: "home#home"

  match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"
  match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "initialize"

  resources :dropbox, only: [:new]
  resources :model_files, only: [:show]
  resources :annotations, only: [:create]
end
