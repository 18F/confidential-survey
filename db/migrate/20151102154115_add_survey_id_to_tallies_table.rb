class AddSurveyIdToTalliesTable < ActiveRecord::Migration
  def up
    remove_index :tallies, [:field, :value]
    add_column :tallies, :survey_id, :string
    add_index :tallies, [:field, :value, :survey_id], unique: true
  end

  def down
    remove_index :tallies, [:field, :value, :survey_id]
    remove_column :tallies, :survey_id
    add_index :tallies, [:field, :value], unique: true
  end
end
