class Intevent < AdServeModel 

  attribute :event_type, :ids
  belongs_to :message
  
  validates :event_type, :numericality => {:greater_than => 0, :less_than => 5}

  validate :ids_exist
  
  def initialize *args
    super(*args)
    self.ids ||= []
  end
  
  def self.applicationEvent
    intevent = new
    intevent.event_type = EventType::APPLICATION
    return intevent
  end

  def ids_exist
    nonexistant = []

    self.ids.each do |id|
      begin
        case id
        when String
          nonexistant << id unless check_id(id) 
        when Hash
          id.each do |k,v|
            nonexistant << k unless check_id(k)
            v.each {|h_id| nonexistant << h_id unless (check_id(h_id))}
          end
        end
      rescue
        nonexistant << id
      end
    end

    errors.add(:ids, "The following ids don't exist #{nonexistant}") if nonexistant.length > 0
    return
  end

  def check_id(id)
    !id.nil? && self.class.exists?(id)
  end

end
