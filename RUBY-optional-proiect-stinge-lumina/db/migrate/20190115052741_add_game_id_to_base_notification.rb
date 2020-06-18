class AddGameIdToBaseNotification < ActiveRecord::Migration[5.2]
  def change
    add_column :base_notifications, :game_id, :integer
  end
end
