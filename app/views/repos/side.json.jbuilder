json.collection @repos do |repo|


  json.repo do
    json.name repo.name
    json.id repo.id
  end

  if build = repo.build_reports.availables.last
    build_time = Time.parse(build.build_time).getutc.iso8601 rescue "-"
    json.build do 
      json.id build.id
      json.build_status build.build_status
      json.status build.status
      json.finished build_time
      json.duration build.to_duration
    end
  end
end