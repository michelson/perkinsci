class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github

    if outsider_githubber?
      redirect_to root_path, alert: "Sorry, invalid github account!"  and return
    end

    @user = User.from_omniauth(request.env["omniauth.auth"])
    
    #token acá, mejor guardarlo
    session[:user_token] = request.env["omniauth.auth"]["credentials"]["token"]
    
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Github") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end

  def outsider_githubber?
    # if the org list empty , will not validate
    return if Rails.application.secrets.allowed_orgs.blank?
    
    cli = Octokit::Client.new(access_token: request.env["omniauth.auth"]["credentials"]["token"])
    orgs = cli.orgs.map{|o| o[:login]}

    check = (orgs & Rails.application.secrets.allowed_orgs).any?

    # check if user belongs to configured organizations
    !check
  end

end