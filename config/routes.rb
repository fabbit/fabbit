Fabbit::Application.routes.draw do
  root to: "home#home"

  resources :dropbox, only: [:new]
  resources :users, only: [:show] do
    resources :model_files, only: [:show] do
      resources :annotations, only: [:index, :create] do
        resource :discussions, only: [:index, :create]
      end

      resources :revisions, only: [:index, :show] do
        resources :annotations, only: [:index, :create] do
          resource :discussions, only: [:index, :create]
        end
      end

      get "contents", on: :member
    end

    match "/model_file/:filename", to: "model_files#init_model_file", filename: /.+/, as: "init_model_file"
    match "/navigate/(:path(/:more_path))", to: "dropbox#navigate", as: "navigate"
  end
end
