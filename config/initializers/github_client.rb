$github_client = Octokit::Client.new(
  access_token: ENV['ACCESS_TOKEN'],
  auto_traversal: true,
  per_page: 100
)