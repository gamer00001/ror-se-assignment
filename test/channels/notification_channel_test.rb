# test/channels/notification_channel_test.rb
require 'test_helper'

class NotificationChannelTest < ActionCable::Channel::TestCase
  def setup
    @user = users(:one) # Assuming you have a user fixture
  end

  test "subscribes to a stream for the current user" do
    stub_connection current_user: @user

    subscribe

    assert subscription.confirmed?
    assert_has_stream_for @user
  end

  test "unsubscribes from all streams" do
    stub_connection current_user: @user

    subscribe
    unsubscribe

    assert_no_streams
  end
end
