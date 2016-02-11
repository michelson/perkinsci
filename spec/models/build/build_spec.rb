require 'spec_helper'

describe "Repo" do

  let(:user_api) {
    Octokit::Client.new(
      login: ENV['LOGIN'],
      access_token: ENV['ACCESS_TOKEN']
    )
  }

  let(:file){
    f = File.expand_path(File.dirname(__FILE__) + '/../../fixtures/.travis.yml')
    Travis::Yaml.parse( File.open(f).read )
  }

  before(:each) do
    Repo.sync_github_repos(github_user)

    to_add = Repo.synced_records.where(name: test_repo[:full_name]).first
    r = Repo.add_from_github(to_add.gb_id)
  end

  context "runner config" do
    before :each do
      @repo = Repo.where(cached: false).last
      allow_any_instance_of(Repo).to receive(:check_config_existence).and_return(file)
    end

    after :each do
      Repo.delete_all
    end

    it "should have a runner" do
      expect(@repo.runner).to_not be_instance_of(Runner)
    end

    it "run run run should add a new report" do
      @repo.load_git
      sha = @repo.git.log.map(&:sha).first
      
      expect_any_instance_of(Octokit::Client).to receive(:create_status).at_most(2).times.and_return(true)

      @repo.runner.report = @repo.build_reports.create
      @repo.runner.report.build_with(sha, "master")
      
      expect(@repo.build_reports.last.build_status).to_not be_blank
      expect(@repo.build_reports.size).to be == 1
    end
  end

end