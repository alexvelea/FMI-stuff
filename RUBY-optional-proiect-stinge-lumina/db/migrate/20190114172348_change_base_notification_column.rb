class ChangeBaseNotificationColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :base_notifications, :viewd, :is_seen
  end
end
