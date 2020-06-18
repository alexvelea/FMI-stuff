class CreateFriendships < ActiveRecord::Migration[5.2]
  def change
    create_table :friendships do |t|
      t.references :user, foreign_key: { to_table: :users }
      t.references :friend, foreign_key: { to_table: :users }
      t.boolean :accepted

      t.timestamps
    end
  end
end
