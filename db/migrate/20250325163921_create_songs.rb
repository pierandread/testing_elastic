class CreateSongs < ActiveRecord::Migration[7.2]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.string :genre
      t.text :lyrics

      t.timestamps
    end
  end
end
