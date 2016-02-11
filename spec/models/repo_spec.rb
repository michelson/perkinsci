require 'rails_helper'

#require "fakeredis"

#$redis = Redis.new

describe "Repo" do

  let(:user_api) {
    Octokit::Client.new(
      login: ENV['LOGIN'],
      access_token: ENV['ACCESS_TOKEN']
    )
  }

  let(:file){
    f = File.expand_path(File.dirname(__FILE__) + '/../fixtures/.travis.yml')
    Travis::Yaml.parse( File.open(f).read )
  }

  #let(:github_user){
  #  Warden::GitHub::User.new
  #}

  before(:all) do
    #allow_any_instance_of(Warden::GitHub::User).to receive(:api).and_return(user_api)
    #@user = Warden::GitHub::User.new
    Repo.sync_github_repos(github_user)
  end

  it "all should return repos" do
    expect(Repo.all).to_not be_blank
    expect(Repo.all.size).to be == Repo.synced_records.size
  end

  it "basic attrs presence" do
    r = Repo.first
    expect(r.name).to_not be_blank
    expect(r.id).to_not be_blank
    expect(r.url).to_not be_blank
  end

  context "load git" do
    before :each do
      @repo = Repo.find_by(name: test_repo[:full_name])
    end

    it "git will be not loaded" do
      expect(@repo.git).to be_blank
    end

    it "will be downloaded after load_git" do
      @repo.load_git
      expect(@repo.git).to be_present
      expect(@repo.git.dir.path).to be == "/tmp/#{@repo.name}"
      expect(File.exist?(@repo.git.dir.path)).to be_present
    end

    it "override dir with virtual_sha" do
      @repo.virtual_sha = test_repo[:sha]
      @repo.load_git
      expect(@repo.git).to be_present
      expect(@repo.git.dir.path).to be == "/tmp/#{@repo.name}#{test_repo[:sha]}"
      expect(File.exist?(@repo.git.dir.path)).to be_present
    end

    it "should have a default runner" do
      @repo.load_git
      expect(@repo.runner).to_not be_blank
    end

    it "should have branches" do
      @repo.load_git
      expect(@repo.runner_branch).to be == ["master"]
      expect(@repo.branches).to include("master")
    end
  end

  context "runner config" do
    before :each do
      @repo = Repo.find_by(name: test_repo[:full_name])
      allow_any_instance_of(Repo).to receive(:check_config_existence).and_return(file)
      @repo.load_git
      expect(@repo.git).to be_instance_of(Git::Base)
      @path = @repo.git.dir.path
    end

    it "should have a runner" do
      expect(@repo.runner).to be_instance_of(Runner)
    end
  end

  context "receive commit" do
    before :each do
      allow_any_instance_of(Repo).to receive(:check_config_existence).and_return(file)
      @repo = Repo.find_by(name: test_repo[:full_name])
    end

    it "will enqueue commit" do
      sha = test_repo[:sha]
      expect(@repo).to receive(:enqueue_commit) #.with(sha, "master")
      @repo.add_commit(sha, "master")
    end

    it "will increment Worker jobs when receive commit " do
      sha = test_repo[:sha]
      @repo.add_commit(sha, "master")
      expect(BuildWorker.jobs.size).to be > 0
    end

  end

end
