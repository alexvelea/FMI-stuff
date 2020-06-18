require 'test_helper'

class FriendshipControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get friendship_new_url
    assert_response :success
  end

  test "should get accept" do
    get friendship_accept_url
    assert_response :success
  end

  test "should get delete" do
    get friendship_delete_url
    assert_response :success
  end

  test "should get status" do
    get friendship_status_url
    assert_response :success
  end

end
