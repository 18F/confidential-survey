class Tally < ActiveRecord::Base
  validates :field, presence: true
  validates :value, presence: true
  validates :survey_id, presence: true
  validates :count, numericality: { only_integer: true,
                                    greater_than_or_equal_to: 0 }

  def self.record(survey_id, field, value)
    t = where(survey_id: survey_id, field: field, value: value).first_or_create
    t.increment!(:count)
    t
  end

  def self.tally_for(survey_id, field, value)
    t = where(survey_id: survey_id, field: field, value: value).first
    t.nil? ? 0 : t.count
  end

  def to_s
    "Tally #{survey_id}:#{field} \"#{value}\": #{count}"
  end
end
