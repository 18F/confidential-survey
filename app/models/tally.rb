class Tally < ActiveRecord::Base
  validates :field, presence: true
  validates :value, presence: true,
                    uniqueness: { scope: :field,
                                  message: 'There should be only one field/value count'}
  validates :count, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0 }

  def self.record(field, value)
    t = where(field: field, value: value).first_or_create
    t.increment!(:count)
    t
  end

  def self.tally_for(field, value)
    t = where(field: field, value: value).first
    t.nil? ? 0 : t.count
  end
end
