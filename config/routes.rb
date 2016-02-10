Rails.application.routes.draw do

  devise_for :users, 
  :controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks" 
  }

  root to: "home#index"

  resources :profile, controller: :profile

  resources :repos do 

  end

  get "/repos/add/:id" => "repos#add"
  get "/repos/:name/:repo" => "repos#show"

  get "/me" => "home#me"
  get "/orgs" => "home#orgs"

end
