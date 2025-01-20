require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects successfully with a valid user" do
    user = users(:one)
    cookies.signed[:user_id] = user.id

    connect "/cable"

    assert_equal user.id, connection.current_user.id
  end

  test "rejects connection with an invalid user" do
    cookies.signed[:user_id] = nil

    assert_raises(ActionCable::Connection::Authorization::UnauthorizedError) do
      connect "/cable"
    end
  end
end
