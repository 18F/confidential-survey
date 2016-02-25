class CreateTokensTable < ActiveRecord::Migration
  def change
    create_table :survey_tokens do |t|
      t.string :survey_id
      t.string :token
    end

    add_index :survey_tokens, :token, unique: true
  end
end
