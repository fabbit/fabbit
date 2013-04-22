Fabbit::Application.routes.draw do

  root to: "home#home"

  resources :dropbox, only: [:new]

  resources :members, only: [:show]

  resources :model_files, only: [:show] do
    resources :annotations, only: [:index, :create]
    resources :revisions, only: [:index, :create]
    get "contents", on: :member
  end

  resources :revisions, only: [:show] do
    resources :annotations, only: [:index, :create]
  end

  resources :annotations, only: [:show] do
    resources :discussions, only: [:index, :create]
  end

  match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "init_model_file"
  match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"

end
