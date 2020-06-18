class BaseNotification < ApplicationRecord
  belongs_to :user, class_name: 'User'

  def all
    result = super
    result
  end

  def self.setup_notifications(user_id)
    puts 'NOTIFIFIFIFIFIFIIFIFIFIFIF'
    if user_id > 0
      $notifications = BaseNotification.where(user_id: $current_user.id)
    end
    ""
  end
end