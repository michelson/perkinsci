class BuildsController < ApplicationController

  def show
    find_repo
    @build = @repo.build_reports.find(params[:id])
  end

  def index
    find_repo
    @builds = @repo.build_reports
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

end
