class NotificationController < ApplicationController
  def destroy
    id = params[:id]
    notification = BaseNotification.find(id)
    notification.delete if notification && (notification.user_id = current_user.id)

    redirect_to '/'
  end
end
