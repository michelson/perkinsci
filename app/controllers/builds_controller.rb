class BuildsController < ApplicationController

  def show
    find_repo
    @build = @repo.build_reports.availables.find(params[:id])
  end

  def index
    find_repo
    @builds = @repo.build_reports.availables
  end

private
  def find_repo
    @repo = Repo.find_by(name: "#{params[:name]}/#{params[:repo]}")
  end

end
