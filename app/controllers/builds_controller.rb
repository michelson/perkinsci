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

  def delete
    if find_repo.build_reports.find(params[:id]).delete
      redirect_to "/repos/#{@repos.name}", notice: "build deleted ok"
    else
      redirect_to "/repos/#{@repos.name}", notice: "error deleting build"
    end
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

end
