module Concerns
  module Receiver
    include ActiveSupport::Concern

    def receiver
      # NEEDS VALIDATIONS
      @payload = JSON.parse request.raw_post
      @payload_id = @payload["repository"]["id"]
      @repo   = Repo.added.find_by(gb_id: @payload["repository"]["id"])
      
      raise "repo not found #{@payload_id}" if @repo.blank?

      receive_payload
      render json: "ok"
    end

    def receive_payload
      receive_push
      receive_pull_request
    end

    def receive_push
      return {} if @payload["ref"].blank? or @payload["after"].blank?
      pushed_branch = @payload["ref"].split('/').last
      @repo.add_commit(@payload["after"], pushed_branch)
      puts "received push on repo: #{@payload_id}".green
    end

    def receive_pull_request
      return {} unless @payload.keys.include?("pull_request") && @payload["action"] == "opened"
      head = @payload["pull_request"]["head"]
      pushed_branch = head["ref"]
      @repo.add_commit(head["sha"], pushed_branch)
      puts "received pull request on repo: #{@payload_id}".green
    end

  end
end