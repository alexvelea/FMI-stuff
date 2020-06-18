class AddDefaultValues < ActiveRecord::Migration[5.2]
  def up
    change_column :base_notifications, :viewd, :boolean, default: false
    change_column :friendships, :accepted, :boolean, default: false
  end

  def down
    change_column :base_notifications, :viewd, :boolean, default: nil
    change_column :friendships, :accepted, :boolean, default: nil
  end
end
