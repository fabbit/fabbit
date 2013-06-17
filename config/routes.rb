Fabbit::Application.routes.draw do

  root to: "home#home"

  resources :dropbox, only: [:new]

  resources :projects, only: [:index, :new, :create]
  resources :project_model_files, only: [:create, :destroy]

  resources :members, only: [:show] do
    resources :model_files, only: [:index]
    resources :projects, only: [:index]
  end

  resources :projects, only: [:show] do
    resources :members, only: [:index]
    resources :model_files, only: [:index]
  end

  resources :model_files, only: [:show] do
    resources :annotations, only: [:index, :create]
    resources :versions, only: [:index, :create]
    resources :dropbox_revisions, only: [:index, :show]

    member do
      get :contents
      # get :dropbox_revisions
      # get "preview/:revision_number", action: "preview", as: "preview"
    end
  end

  resources :versions, only: [:show, :destroy] do
    resources :annotations, only: [:index, :create]

    member do
      get :contents
    end
  end

  resources :annotations, only: [:show] do
    resources :discussions, only: [:index, :create]
  end

  match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "init_model_file"
  match "/navigate/(:dropbox_path)", to: "dropbox#navigate", dropbox_path: /.+/, as: "navigate"
  # match "/navigate", to: "dropbox#navigate"
  # match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"
  # NOTE: should I change this to the same format as init_model_file?

end
