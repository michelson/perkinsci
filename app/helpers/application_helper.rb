require 'digest'

module ApplicationHelper

  def gravatar_url(email, size)
    md5 = Digest::MD5.new
    gravatar_id = md5.update email
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  def commit_url(sha)
    "#{current_repo.get("http_url")}/commit/#{sha}"
  end

  def status_label(status)
    label = status == true ? "success": "default"
    msg   = status == true ? "passed" : "error"
    "<span class='label label-#{label}'>build | #{msg}</span>"
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
