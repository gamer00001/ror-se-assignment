class Employee
  include ActiveModel::Model

  attr_accessor :name, :position, :date_of_birth, :salary, :id, :created_at, :updated_at

  validates :name, presence: true, length: { maximum: 100 }
  validates :position, presence: true, length: { maximum: 50 }
  validates :date_of_birth, presence: true
  validates :salary, presence: true, numericality: { greater_than: 0 }

  validate :date_of_birth_not_in_future

  def date_of_birth=(value)
    @date_of_birth = Date.parse(value) rescue nil
  end

  private

  def date_of_birth_not_in_future
    if date_of_birth && date_of_birth > Date.today
      errors.add(:date_of_birth, "can't be in the future")
    end
  end
end
