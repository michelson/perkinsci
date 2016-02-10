require 'net/http'
require "uri"

class BuildWorker

  include Sidekiq::Worker

  def perform(report_id, sha, branch)
    report = BuildReport.find(report_id)
    report.build_with(sha, branch)
  end

end
