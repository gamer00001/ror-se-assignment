require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @blog = Blog.new(
      title: "Valid Title",
      body: "This is a valid body with meaningful content.",
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @blog.valid?
  end

  test "should not be valid without a title" do
    @blog.title = nil
    assert_not @blog.valid?
    assert_includes @blog.errors[:title], "can't be blank"
  end

  test "should not be valid with a title shorter than 3 characters" do
    @blog.title = "AB"
    assert_not @blog.valid?
    assert_includes @blog.errors[:title], "is too short (minimum is 3 characters)"
  end

  test "should not be valid with a title longer than 120 characters" do
    @blog.title = "A" * 121
    assert_not @blog.valid?
    assert_includes @blog.errors[:title], "is too long (maximum is 120 characters)"
  end

  test "should not be valid with a title containing only special characters" do
    @blog.title = "!!!@@@###"
    assert_not @blog.valid?
    assert_includes @blog.errors[:title], "must contain letters and/or numbers, not just special characters"
  end

  test "should not be valid without a body" do
    @blog.body = nil
    assert_not @blog.valid?
    assert_includes @blog.errors[:body], "can't be blank"
  end

  test "should not be valid with a body shorter than 10 characters" do
    @blog.body = "Short"
    assert_not @blog.valid?
    assert_includes @blog.errors[:body], "is too short (minimum is 10 characters)"
  end

  test "should not be valid with a body longer than 10000 characters" do
    @blog.body = "A" * 10001
    assert_not @blog.valid?
    assert_includes @blog.errors[:body], "is too long (maximum is 10000 characters)"
  end

  test "should not be valid with a body containing invalid characters" do
    @blog.body = "Invalid body with emoji 😊"
    assert_not @blog.valid?
    assert_includes @blog.errors[:body], "must contain meaningful text and punctuation"
  end

  test "should not be valid without a user" do
    @blog.user = nil
    assert_not @blog.valid?
    assert_includes @blog.errors[:user], "must exist"
  end
end
