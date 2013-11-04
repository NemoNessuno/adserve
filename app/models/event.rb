require 'date'

class Event < AdServeModel 

  attribute :event_date, :target_id

  validates :target_id, :presence => true
  validate  :validate_event_date

  def parsedDate
    Date.parse(event_date)
  end

  def validate_event_date
    begin
      if (parsedDate.blank? or parsedDate > Date.today)
        errors.add(:event_date, "is empty or lies in the future")
      end
    rescue
      errors.add(:event_date, 'is not a valid datetime')
    end
  end

end
