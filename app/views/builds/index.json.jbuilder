json.collection @builds do |build|

  json.repo do 
    json.id build.repo.id
    json.name build.repo.name
  end

  json.build do 
    json.id build.id
    json.status build.status
    json.build_status build.build_status 
    json.commit( build.commit.present? ? build.commit[:commit] : {})
    json.sha( build.sha.present? ? build.sha[0..7] : "")
    json.branch "(#{build.branch})"
    json.duration build.to_duration || "-"
    json.build_time build.build_time
    json.finished build.build_time
  end
  
end