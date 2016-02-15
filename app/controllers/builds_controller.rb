class BuildsController < ApplicationController

  before_action :authenticate_user!

  def show
    find_repo
    @build = @repo.build_reports.find(params[:id])
  end

  def index
    find_repo
    @builds = @repo.build_reports.order("id desc")
  end

  def replay
    find_repo
    @build = @repo.build_reports.find(params[:id])
    if @repo.add_commit(@build.sha, @build.branch)
      render json: {status: "ok"}
    end
    #redirect_to "/repos/#{@repo.name}" , notice: "Re enqueued build"  
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

end
