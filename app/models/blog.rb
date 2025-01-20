class Blog < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3, maximum: 120 },
                  format: { with: /\A[A-Za-z0-9\s]+\z/, message: "must contain letters and/or numbers, not just special characters" }
  validates :body, presence: true, length: { minimum: 10, maximum: 10000 },
                 format: { with: /\A[A-Za-z0-9\s[:punct:]]+\z/, message: "must contain meaningful text and punctuation" }

end
