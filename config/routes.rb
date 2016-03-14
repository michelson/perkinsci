require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

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
    collection do 
      post :receiver
      get :side
    end
  end

  #post "/repos/receiver" => "repos#receiver"
  #get "/repos/side" => "repos#side"

  get "/repos/add/:id" => "repos#add"
  get "/repos/:name/:repo" => "repos#show"
  get "/repos/:name/:repo/run_commit" => "repos#run_commit"
  get "/repos/:name/:repo/badge" => "repos#badge"

  get "/repos/:name/:repo/builds" => "builds#index"
  get "/repos/:name/:repo/builds/:id" => "builds#show"
  delete "/repos/:name/:repo/builds/:id" => "builds#delete"
  get "/repos/:name/:repo/builds/:id/replay" => "builds#replay"

  get "/me" => "home#me"
  get "/orgs" => "home#orgs"

end
