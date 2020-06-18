require 'test_helper'

class GameControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get game_new_url
    assert_response :success
  end

  test "should get create" do
    get game_create_url
    assert_response :success
  end

  test "should get show" do
    get game_show_url
    assert_response :success
  end

  test "should get update" do
    get game_update_url
    assert_response :success
  end

  test "should get edit" do
    get game_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get game_destroy_url
    assert_response :success
  end

end
