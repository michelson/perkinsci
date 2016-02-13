require 'rails_helper'

describe "Repo" do

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
  end

end