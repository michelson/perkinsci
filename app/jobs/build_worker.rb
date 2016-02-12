class BuildWorker

  include Sidekiq::Worker

  def perform(report_id, sha, branch)
    report = BuildReport.find(report_id)
    repo = report.repo
    # execute the build unless there is any build already in progress
    return if report.repo.build_reports.started.any?
    # execute build
    report.build_with(sha, branch)
  end

end
