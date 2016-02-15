json.resource do
  json.repo @repo

  build_time = Time.parse(@build.build_time).getutc.iso8601 rescue "-"
  
  if @build.present? 
    json.build do
      json.id @build.id
      json.build_status @build.build_status
      json.status @build.status
      json.branch @build.branch
      json.sha @build.sha
      json.commit @build.commit
      json.build_time build_time
      json.duration @build.to_duration
    end
  else
    json.build {}
  end

end