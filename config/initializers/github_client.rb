
Octokit.configure do |c|
  c.api_endpoint = "#{ENV['GITHUB_URL']}/api/v3"
  c.web_endpoint = "#{ENV['GITHUB_URL']}/"
end

$github_client = Octokit::Client.new(
  access_token: ENV['ACCESS_TOKEN'],
  auto_traversal: true,
  per_page: 100
  )