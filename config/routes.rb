require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users, 
  :controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks" 
  }

  authenticate :user do
    mount Sidekiq::Web => '/jobs'
  end

  root to: "home#index"

  resources :profile, controller: :profile

  resources :repos do 

  end

  get "/repos/add/:id" => "repos#add"
  get "/repos/:name/:repo" => "repos#show"
  get "/repos/:name/:repo/run_commit" => "repos#run_commit"

  get "/me" => "home#me"
  get "/orgs" => "home#orgs"

end
