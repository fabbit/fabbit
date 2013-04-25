Fabbit::Application.routes.draw do

  root to: "home#home"

  resources :dropbox, only: [:new]

  resources :projects, only: [:index, :new, :create]
  resources :project_members, only: [:create, :destroy]

  resources :projects, only: [:show] do
    resources :members, only: [:index]
  end

  resources :members, only: [:show] do
    resources :projects, only: [:index]
  end

  resources :model_files, only: [:show] do
    resources :annotations, only: [:index, :create]
    resources :versions, only: [:index, :create]

    member do
      get :contents
      get :dropbox_revisions
    end
  end

  resources :versions, only: [:show, :destroy] do
    resources :annotations, only: [:index, :create]
  end

  resources :annotations, only: [:show] do
    resources :discussions, only: [:index, :create]
  end

  match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "init_model_file"
  match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"

end
