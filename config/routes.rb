Rails.application.routes.draw do

  devise_for :users
  root to: "home#index"


  resources :repos do 

  end

  get "/me" => "home#me"
  get "/orgs" => "home#orgs"

end
