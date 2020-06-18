class CreateUsersGames < ActiveRecord::Migration[5.2]
  def change
    create_table :users_games, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :game, index: true
    end
  end
end
