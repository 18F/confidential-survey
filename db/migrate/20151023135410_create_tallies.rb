class CreateTallies < ActiveRecord::Migration
  def change
    create_table :tallies do |t|
      t.string :field, limit: 1024, null: false
      t.string :value, limit: 1024, null: false
      t.integer :count, null: false, default: 0
      t.timestamps null: false
    end

    add_index :tallies, [:field, :value], unique: true
  end
end
