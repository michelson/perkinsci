class CreateRepos < ActiveRecord::Migration[5.0]
  def change
    create_table :repos do |t|
      t.string :url
      t.string :name
      t.string :working_dir
      t.string :branch
      t.integer :gb_id
      t.text :github_data
      t.boolean :cached
      t.string :build_status
      t.string :download_status
      t.integer :hook_id

      t.timestamps
    end
  end
end
