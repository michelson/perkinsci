require 'rails_helper'

RSpec.describe ReposController, type: :controller do

  #include Rack::Test::Methods

  let(:repo){
    create(:repo, cached: false)
  }

  describe "receiver" do 
    let(:pull_request){
      JSON.parse(File.open([Rails.root, "spec/fixtures/pull_request_hook.json"].join("/")).read)
    }

    let(:push){
      JSON.parse(File.open([Rails.root, "spec/fixtures/commit_from_push_hook.json"].join("/")).read)
    }

    def hook_receiver(params)
      post :receiver, params.to_json
    end

    it "pull request will raise exception" do
      repo
      controller.request.headers['X-GitHub-Event'] = 'pull_request'
      @request.set_header 'Content_Type', 'application/json'
      expect{hook_receiver(pull_request)}.to raise_error
    end

    it "push will receive add_commit once" do
      repo
      controller.request.headers['X-GitHub-Event'] = 'push'
      @request.set_header 'Content_Type', 'application/json'
      expect_any_instance_of(Repo).to receive(:add_commit).once
      hook_receiver(push)
    end

  end

end
