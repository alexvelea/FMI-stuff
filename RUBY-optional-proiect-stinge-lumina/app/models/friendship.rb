
class Friendship < ApplicationRecord
  NONE = 0
  PENDING = 1
  ACCEPT = 2
  FRIENDS = 3

  def self.friendship_status(user_id, friend_id)
    sql = "SELECT f.accepted FROM users u
          JOIN friendships f
          ON f.friend_id = u.id
          WHERE f.user_id = #{user_id} AND f.friend_id = #{friend_id}"

    a = ActiveRecord::Base.connection.execute(sql)

    if a.length == 1
      return FRIENDS if a[0]['accepted'] == 1

      return PENDING
    end

    sql = "SELECT f.accepted FROM users u
          JOIN friendships f
          ON f.friend_id = u.id
          WHERE f.user_id = #{friend_id} AND f.friend_id = #{user_id}"
    b = ActiveRecord::Base.connection.execute(sql)

    return ACCEPT if b.length == 1

    NONE
  end

  def self.pending(user_id)
    sql = "SELECT u.* FROM users u
          JOIN friendships f
          ON f.friend_id = u.id
          WHERE f.user_id = #{user_id} AND accepted IS NOT 1"
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.requests(user_id)
    sql = "SELECT u.* FROM users u
          JOIN friendships f
          ON f.friend_id = u.id
          WHERE f.friend_id = #{user_id} AND accepted IS NOT 1"
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.friends(user_id)
    sql = "SELECT u.* FROM users u
          JOIN friendships f
          ON f.friend_id = u.id
          WHERE f.friend_id = #{user_id} AND accepted == 1"
    ActiveRecord::Base.connection.execute(sql)
  end

end
