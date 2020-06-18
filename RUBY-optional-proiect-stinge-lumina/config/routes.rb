Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  authenticate :user do
    resources :home, only: [:index, :about, :rules]
    resources :game
    resources :friendship, only: [] do
      collection do
        get 'create'
        get 'accept'
        get 'destroy'
      end
    end
    resources :notification, only: [:destroy]
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
end
