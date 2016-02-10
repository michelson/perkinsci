class ReposController < ApplicationController


  def index
    
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
