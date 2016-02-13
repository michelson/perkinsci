class BuildsController < ApplicationController

  def show
    find_repo
    @build = @repo.build_reports.find(params[:id])
  end

  def index
    find_repo
    @builds = @repo.build_reports
  end

  def replay
    find_repo
    @build = @repo.build_reports.find(params[:id])
    @repo.add_commit(@build.sha, @build.branch)
    redirect_to "/repos/#{@repo.name}" , notice: "Re enqueued build"  
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

end
