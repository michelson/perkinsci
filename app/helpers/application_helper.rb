require 'digest'

module ApplicationHelper

  def gravatar_url(email, size)
    md5 = Digest::MD5.new
    gravatar_id = md5.update email
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  def commit_url(build)
    "#{build.repo.http_url}/commit/#{build.sha}"
  end

  def status_label(status)
    label = status == true ? "success": "default"
    msg   = status == true ? "passed" : "error"
    raw "<span class='label label-#{label}'>build | #{msg}</span>"
  end

  def status_icon(build)
    if build.blank? or build.queued?
      raw "<i class='material-icons'>watch_later</i>"
    elsif build.started?
      raw "<i class='material-icons'>cached</i>"
    elsif build.build_status == "stopped"
      if build.status? 
        raw "<i class='material-icons'>done</i>"
      else
        raw "<i class='material-icons'>bug report</i>" 
      end
    end
  end

  def build_color(build)
    if build.blank? or build.build_status == "started"
      "black"
    elsif build.build_status == "stopped"
      if build.status? 
        "green"
      else
        "red"
      end
    end
  end

  def status_class(status)
    status == true ? "glyphicon glyphicon-ok" : "glyphicon glyphicon-remove"
  end

  def round(int, decimals=2)
    #Math.round(int * 100) / 100
    #+int.toFixed(2);
    parseFloat(int).toFixed(decimals)
  end

end
