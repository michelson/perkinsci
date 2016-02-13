class GitLoaderWorker

  include Sidekiq::Worker

  def perform(repo_id)
    repo = Repo.find(repo_id)
    #return if repo.downloading? or repo.downloaded?
    #it actually clone repo and instantiates git data
    repo.load_git
  end
end
