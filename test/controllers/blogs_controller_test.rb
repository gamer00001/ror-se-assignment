require "test_helper"

class BlogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  
  setup do
    @blog = blogs(:one)
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get blogs_url
    assert_response :success
  end

  test "should get new" do
    get new_blog_url
    assert_response :success
  end

  test "should create blog" do
    assert_difference("Blog.count") do
      post blogs_url, params: { blog: { body: @blog.body, title: @blog.title, user_id: @blog.user_id } }
    end

    assert_redirected_to blog_url(Blog.last)
  end

  test "should show blog" do
    get blog_url(@blog)
    assert_response :success
  end

  test "should get edit" do
    get edit_blog_url(@blog)
    assert_response :success
  end

  test "should update blog" do
    patch blog_url(@blog), params: { blog: { body: @blog.body, title: @blog.title, user_id: @blog.user_id } }
    assert_redirected_to blog_url(@blog)
  end

  test "should destroy blog" do
    assert_difference("Blog.count", -1) do
      delete blog_url(@blog)
    end

    assert_redirected_to blogs_url
  end

  test "should redirect if no file is uploaded" do
    post import_blogs_path
    assert_redirected_to blogs_path
    assert_equal 'No file uploaded. Please upload a CSV file.', flash[:alert]
  end

  test "should redirect if invalid file is uploaded" do
    invalid_file = fixture_file_upload('sample.txt', 'text/plain')
    post import_blogs_path, params: { attachment: invalid_file }
    assert_redirected_to blogs_path
    assert_equal 'Please upload a valid CSV file.', flash[:alert]
  end

  test "should enqueue job and redirect for valid CSV file" do
    csv_file = fixture_file_upload('test_data.csv', 'text/csv')

    assert_enqueued_jobs 1 do
      post import_blogs_path, params: { attachment: csv_file }
    end

    assert_redirected_to blogs_path
    assert_equal 'Your file is being processed. You will be notified once the import is complete.', flash[:notice]
  end
end
