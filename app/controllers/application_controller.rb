class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def github_user
    Octokit::Client.new(:access_token => session[:user_token])
  end

  def github_repos
    @github_repos ||= persisted_repos.any? ? persisted_repos : build_data
  end

  def build_data
    Repo.sync_github_repos(github_user)
    redirect "/me"
  end

  def persisted_repos
    Repo.synced_records
  end

end
