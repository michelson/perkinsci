class ReposController < ApplicationController

  def index
    @repos = Repo.added.all
  end

  def run_commit

    @repo = find_repo
    sha = $github_client
      .refs(@repo.name, "heads/master", per_page: 1)[:object][:sha]
    #sha = github_user.api.commits(repo.name).first[:sha]
    @repo.add_commit(sha, "master")
    redirect_to "/repos/#{@repo.name}"
    #repo.to_json

  end

  def receiver
    #NEEDS VALIDATIONS
    payload = JSON.parse request.raw_post
    repo    = Repo.added.find_by(gb_id: payload["repository"]["id"])
    #repo.load_git
    return {} if payload["ref"].blank? or payload["after"].blank?
    pushed_branch = payload["ref"].split('/').last
    repo.add_commit(payload["after"], pushed_branch)
    "received post #{payload}"
    render text: "ok"
  end

  def add_hook
    repo = find_repo
    hook = repo.add_hook(params[:webhook_url])
    hook.try(:to_attrs).try(:to_json) || {}.to_json
  end

  def show
    find_repo
  end

  def add
    Repo.add_repo(params[:id])
    redirect_to "/"
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end
end
