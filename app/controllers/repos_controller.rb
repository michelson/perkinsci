class ReposController < ApplicationController

  include Concerns::Receiver

  before_action :authenticate_user!, except: :receiver
  protect_from_forgery :only => :receiver

  def index
    @repos = Repo.added.all
  end

  def side
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

  def add_hook
    repo = find_repo
    hook = repo.add_hook(params[:webhook_url])
    hook.try(:to_attrs).try(:to_json) || {}.to_json
  end

  def show
    find_repo
    @build = @repo.build_reports.last
    @builds = @repo.build_reports.order("id desc")
  end

  def add
    Repo.add_repo(params[:id])
    redirect_to "/"
  end

  def badge
    find_repo
    build = @repo.build_reports.last
    contents = request_badge({status: build.status ? "passing" : "error" , color: build.status ? "green" : "red" })
    #render file: filename, content_type: "image/svg+xml"
    send_data contents, type: "image/svg+xml", disposition: 'inline'
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

  def request_badge(opts={})
    begin
      image_path = "https://img.shields.io/badge/build-#{opts[:status]}-#{opts[:color]}.svg?style=flat-square"
      url = URI.parse(image_path)
      result = Net::HTTP.get(url)
    rescue => e
      e
    end
  end
end
