class ProfileController < ApplicationController

  def index
    #@github_repos = github_user.repositories
    @github_orgs = github_user.orgs
  end

  def show
    if params["id"] != "me"
      @org  = github_user.organization(params['id'])
      @github_repos = github_user.org_repos(params["id"])
    else
      @github_repos = github_user.repositories
    end
  end
end
