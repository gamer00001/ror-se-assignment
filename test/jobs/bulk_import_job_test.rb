require "test_helper"
require 'mocha/minitest'

class BulkImportJobTest < ActiveJob::TestCase
  setup do
    @blog = blogs(:one)
    @user = users(:one)
    @file_path = Rails.root.join('test', 'fixtures', 'files', 'sample.csv').to_s
    @file_name = 'sample.csv'
  end

  test 'processes CSV file and inserts valid rows' do
    SmarterCSV.stubs(:process).yields([{ 'title' => @blog.title, 'body': @blog.body }])

    assert_enqueued_with(job: BulkImportJob) do
      BulkImportJob.perform_later(@user.id, @file_path, @file_name)
    end

    assert_equal 1, Blog.count
  end

  test 'counts invalid rows and handles them properly' do
    SmarterCSV.stubs(:process).yields([{ 'title' => nil }])

    assert_enqueued_with(job: BulkImportJob) do
      BulkImportJob.perform_later(@user.id, @file_path, @file_name)
    end

    assert_equal 1, Blog.count
  end

  test 'does not process the file when user does not exist' do
    assert_no_changes -> { Blog.count } do
      BulkImportJob.perform_later(nil, @file_path, @file_name)
    end
  end

  test 'logs an error and deletes the file on processing error' do
    SmarterCSV.stubs(:process).raises(SmarterCSV::SmarterCSVException, 'Processing error')
  
    BulkImportJob.perform_later(@user.id, @file_path.to_s, @file_name)
  
    assert_enqueued_jobs 1
    perform_enqueued_jobs
    assert_not File.exist?(@file_path), "File should be deleted after processing error"  
    assert_equal 1, Blog.count
  end
  

  test 'logs an error and deletes the file on ActiveRecord error' do
    SmarterCSV.stubs(:process).yields([{ 'title' => @blog.title, 'body': @blog.body }])
    Blog.stubs(:insert_all!).raises(ActiveRecord::StatementInvalid, 'Statement error')

    BulkImportJob.perform_later(@user.id, @file_path.to_s, @file_name)
  
    assert_enqueued_jobs 1
    perform_enqueued_jobs
  
    assert_not File.exist?(@file_path), "File should be deleted after processing error"
  
    assert_equal 1, Blog.count
  end

  test 'logs an error and deletes the file on standard error' do
    SmarterCSV.stubs(:process).raises(StandardError, 'Unexpected error')

    BulkImportJob.perform_later(@user.id, @file_path.to_s, @file_name)
  
    assert_enqueued_jobs 1
    perform_enqueued_jobs
  
    assert_not File.exist?(@file_path), "File should be deleted after processing error"
  
    assert_equal 1, Blog.count
  end
end
