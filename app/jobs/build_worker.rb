require 'net/http'
require "uri"

class BuildWorker

  include Sidekiq::Worker

  def perform(report_id, sha, branch)
    report = BuildReport.find(report_id)
    repo = report.repo
    # execute the build unless there is any build already in progress
    return if report.repo.started.any?
    
    report.build_with(sha, branch)
  end

end
