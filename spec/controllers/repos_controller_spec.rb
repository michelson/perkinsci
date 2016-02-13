require 'rails_helper'

RSpec.describe ReposController, type: :controller do

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
      post :receiver, params.to_json, {'Content-Type' => 'application/json'}
    end

    it "pull request will receive add_commit once" do
      repo
      expect_any_instance_of(Repo).to receive(:add_commit).once
      hook_receiver(pull_request)
    end

    it "push request will receive add_commit once" do
      repo
      expect_any_instance_of(Repo).to receive(:add_commit).once
      hook_receiver(push)
    end

  end

end
