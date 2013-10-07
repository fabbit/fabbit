Fabbit::Application.routes.draw do

  root to: "home#home"

  resources :dropbox, only: [:new]

  resources :groups, only: [:show]
  resources :group_members, only: [:create, :destroy]
  resources :group_projects, only: [:create, :destroy]

  resources :projects, only: [:index, :new, :create]
  resources :project_model_files, only: [:create, :destroy] do
    post :add_all, on: :collection
  end

  resources :members, only: [:show] do
    resources :model_files, only: [:index]
    resources :projects, only: [:index]
  end

  resources :projects, only: [:show] do
    resources :members, only: [:index, :show]
  end

  resources :model_files, only: [:show] do
    resources :versions, only: [:create, :destroy]
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

  resources :notifications, only: [:index, :update]

  match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "init_model_file"
  match "/navigate/(:dropbox_path)", to: "dropbox#navigate", dropbox_path: /.+/, as: "navigate"
  match "directories/", to: "dropbox#directories"

end
