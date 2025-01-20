class BulkImportJob < ApplicationJob
  queue_as :default

  CHUNK_SIZE = (ENV['CHUNK_SIZE'].presence || 1000).to_i

  def perform(user_id, file_path, file_name)
    user = User.find_by(id: user_id)
    return unless user.present?

    invalid_rows = 0
    begin
      SmarterCSV.process(file_path, chunk_size: CHUNK_SIZE, remove_empty_hashes: true) do |chunk|
        blogs = []
        ActiveRecord::Base.transaction do
          chunk.each do |row|
            blog_attributes = row.merge(user_id: user.id)
            if Blog.new(blog_attributes).valid?
              blogs << blog_attributes.slice(*Blog.column_names.map(&:to_sym)) # Ensure correct columns
            else
              invalid_rows += 1
            end
          end

          Blog.insert_all!(blogs) if blogs.any?
        end
      end

      NotifcationChannel.broadcast_to(
        user,
        { message: "#{file_name} file is processed with #{invalid_rows} invalid rows.", success: true}
      )

    rescue SmarterCSV::SmarterCSVException => e

      NotifcationChannel.broadcast_to(
        user,
        { message: "Error while processing file #{file_name}. Error: #{e.message}", success: false }
      )

    rescue ActiveRecord::StatementInvalid => e

      NotifcationChannel.broadcast_to(
        user,
        { message: "Error while inserting the records from file #{file_name}. Error: #{e.message}", success: false }
      )

    rescue StandardError => e

      NotifcationChannel.broadcast_to(
        user,
        { message: "Unexpected error while processing file #{file_name}. Error: #{e.message}", success: false }
      )

    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end
