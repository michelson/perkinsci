class AddGithubTokenToRepo < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :token, :string
  end
end
