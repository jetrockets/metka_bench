class CreateBenchmarkTables < ActiveRecord::Migration[6.0]
  def change
    create_table :acts_as_taggable_songs do |t|
      t.string :name
    end

    create_table :acts_as_taggable_array_songs do |t|
      t.string :name
      t.string :genres, array: true, default: []
    end
    add_index :acts_as_taggable_array_songs, :genres, using: 'gin'

    create_table :metka_songs do |t|
      t.string :name
      t.string :genres, array: true
    end
    add_index :metka_songs, :genres, using: 'gin'

    create_table :tag_columns_songs do |t|
      t.string :name
      t.string :genres, array: true, default: [], null: false
    end
    add_index :tag_columns_songs, :genres, using: 'gin'
  end
end
