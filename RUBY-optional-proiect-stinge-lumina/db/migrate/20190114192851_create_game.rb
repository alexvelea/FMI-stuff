class CreateGame < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.references :owner, foreign_key: { to_table: :users }
      t.references :user_to_move, foreign_key: { to_table: :users }

      t.text :game_data
      t.boolean :is_finished, options: { default: false }

      t.timestamps
    end
  end
end
