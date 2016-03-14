require 'rails_helper'

describe Runner do

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

  before(:each) do
    Repo.delete_all
    Repo.sync_github_repos(github_user)
    to_add = Repo.synced_records.where(name: test_repo[:full_name]).first
    Repo.add_from_github(to_add.gb_id)
  end


  context "in repo" do
    let( :repo ){ Repo.find_by(name: "michelson/lazy_high_charts") }
    before :each do
      @runner = Runner.new
      @runner.config = file
      @runner.repo = repo

      @report = BuildReport.new
      @report.sha = "master" 
      @report.branch = "master"

      @runner.repo.build_reports << @report
      @runner.repo.save

      @runner.report = @report
    end

    it "runner should raise error in case it fails" do
      expect{@runner.run!}.to raise_error
    end

    it "should install bundler" do
      expect_any_instance_of(Octokit::Client).to receive(:create_status).at_most(2).times.and_return(true)
      expect{@report.build_with("master")}.to_not raise_error
      expect(@report.reload.duration.to_f).to be > 0
      expect(@report.build_status).to be == "stopped"
    end

  end

  context "a go repo" do
    let( :repo ){ Repo.find_by(name: "michelson/godard") }
    before :each do
      repo.load_git
      @runner = repo.runner

      report = BuildReport.new
      report.sha = "master" 
      report.branch = "master"
      repo.build_reports << report
      repo.branch = "master"
      repo.save
      @runner.report = report

    end

    it "should install bundler" do
      expect_any_instance_of(Octokit::Client).to receive(:create_status).at_most(2).times.and_return(true)
      # expect{@runner.run("master")}.to_not raise_error
      @runner.run("master")
      expect(@runner.duration).to be > 0
      expect(@runner).to_not be_running
    end

  end

  context "build report" do 

    let( :repo ){ Repo.find_by(name: "michelson/godard") }
    before :each do
      repo.load_git
      @runner = repo.runner


      @report = BuildReport.new
      @report.sha = "master" 
      @report.branch = "master"
      repo.build_reports << @report
      repo.branch = "master"
      repo.save
      @runner.report = @report

    end

    it "retrieve_commit_info" do 
      @report.retrieve_commit_info
    end
  end

  context "build report" do 

    let( :repo ){ Repo.find_by(name: "michelson/godard") }
    before :each do

      repo.load_git
      @runner = repo.runner

      @report = BuildReport.new
      @report.sha = "master" 
      @report.branch = "master"
      repo.build_reports << @report
      repo.branch = "master"
      repo.save
      @runner.report = @report

    end

    it "retrieve_commit_info" do 
      @report.retrieve_commit_info
    end
  end

end

