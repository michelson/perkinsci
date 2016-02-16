module Concerns
  module Receiver
    include ActiveSupport::Concern

    GITHUB_EVENTS_WHITELIST = %w( push )

    def receiver
      check_github_event!

      @payload = JSON.parse request.raw_post
      @payload_id = @payload["repository"]["id"]
      @repo   = Repo.added.find_by(gb_id: @payload["repository"]["id"])
      
      raise "repo not found #{@payload_id}" if @repo.blank?

      receive_payload
      render json: "ok"
    end

    def receive_payload
      case request.headers['X-GitHub-Event']
      when "push" then receive_push 
      when "pull_request" then receive_pull_request
      else
        raise "not implemented receiver for #{request.headers['X-GitHub-Event']}"
      end
    end

    def receive_push
      # return {} if @payload["ref"].blank? or @payload["after"].blank?
      pushed_branch = @payload["ref"].split('/').last
      # will skip if head commit is blank!
      @repo.add_commit(@payload["after"], pushed_branch) unless @payload["head_commit"].blank?
      puts "received push on repo: #{@payload_id}".green
    end

    def receive_pull_request
      # return {} unless @payload.keys.include?("pull_request") && @payload["action"] == "opened"
      head = @payload["pull_request"]["head"]
      pushed_branch = head["ref"]
      @repo.add_commit(head["sha"], pushed_branch)
      puts "received pull request on repo: #{@payload_id}".green
    end

  private

    def check_github_event!
      unless GITHUB_EVENTS_WHITELIST.include?(request.headers['X-GitHub-Event'])
        raise "#{request.headers['X-GitHub-Event']} is not a whiltelisted GitHub event."
      end
    end

  end
end