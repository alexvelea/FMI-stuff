class FriendshipController < ApplicationController
  def create
    friend_id = params[:friend_id]
    f = Friendship.find_by(user_id: current_user.id, friend_id: friend_id)
    message = if f
                if f.accepted
                  "You are already friend with #{friend_id}"
                else
                  "You have a pending friend friend request from #{friend_id}"
                end
              else
                Friendship.create(user_id: current_user.id, friend_id: friend_id)
                FriendRequestNotification.create(user_id: friend_id, friend_id: current_user.id)
                'Friendship request send!'
              end
    flash[:notice] = message
    redirect_to '/'
  end

  def accept
    user_id = params[:user_id]
    f = Friendship.find_by('user_id': user_id, friend_id: current_user.id)
    message = if f
                if f.accepted
                  "You are already friend with #{user_id}"
                else
                  f.accepted = true
                  f.save
                  Friendship.create(user_id: current_user.id, friend_id: user_id, accepted: true)
                  FriendRequestNotification.where(user_id: current_user.id, friend_id: user_id).take.delete
                  # TODO(@VELEA) send @notification to {user_id} that the friendship has been made
                  'Friendship request accepted!!!!'
                end
              else
                "You don't have a friendship request from #{user_id}"
              end
    flash[:notice] = message
    redirect_to '/'
  end

  def destroy
    friend_id = params[:friend_id]
    f = Friendship.find_by('user_id': current_user.id, friend_id: friend_id)
    message = if f
                if f.accepted
                  Friendship.find_by('user_id': friend_id, friend_id: current_user.id).destroy
                  f.destroy
                  "You are no longer friend with #{friend_id}"
                else
                  f.destroy
                  'Friend request canceled'
                end
              else
                "No friendship status with #{friend_id}"
              end
    flash[:notice] = message
    redirect_to '/'
  end

  def status
  end
end
