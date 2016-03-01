class JobQueuer
  
  include Sidekiq::Worker
  
  def perform(*args)

    # iterate al repos
    Repo.all.find_each do |repo|
      collection = repo.build_reports
      # find if there is an enqueued
      if report = collection.where(build_status: "queued").order("created_at DESC").last
        # start job only if there are not started build for this repo
        report.enqueue unless collection.where(build_status: "started").any?
      end
    end

  end
end