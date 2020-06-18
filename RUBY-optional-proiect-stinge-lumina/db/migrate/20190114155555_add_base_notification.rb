class AddBaseNotification < ActiveRecord::Migration[5.2]
  def change
    create_table :base_notifications do |t|
      t.string :type
      t.references :user, foreign_key: { to_table: :users }
      t.boolean :viewd

      # friend request notification
      t.references :friend, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
