class CreateBuildReports < ActiveRecord::Migration[5.0]
  def change
    create_table :build_reports do |t|
      t.string :sha
      t.string :branch
      t.string :build_time
      t.string :duration
      t.text :response, :limit => 4294967295
      t.boolean :status
      t.references :repo, foreign_key: true
      t.string :build_status
      t.text :commit

      t.timestamps
    end
  end
end
