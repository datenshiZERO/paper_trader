Rails.application.routes.draw do
  resources :securities do
    member do
      get 'buy'
      post 'process_buy'
      get 'sell'
      post 'process_sell'
    end
  end

  devise_for :users
  devise_scope :user do
    get 'login', :to => 'devise/sessions#new'
    delete 'logout', :to => 'devise/sessions#destroy'
    get 'register', :to => 'registrations#new'
    get 'settings', :to => 'devise/registrations#edit'
  end
  devise_for :admins

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'pages#index'
end
