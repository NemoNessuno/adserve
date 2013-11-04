class Website < AdServeModel
  
  belongs_to :publisher
  has_many :zone
  
  attribute :name, :base_url,
            :description, :categories
  
  attr_accessor :zone_strings

  validates :name,      :presence => true,
                        :format => {:with => /^[0-9a-zA-Z ]+$/},
                        :length => { :minimum => 1, :maximum => 128 }

  validates :description, :presence => true,
                          :format => {:with => /^[0-9a-zA-Z ]+$/}

  validates :base_url,  :presence => true
  
  validate :owner_exists_and_is_a_publisher
  validate :base_url_is_valid

  def owner_exists_and_is_a_publisher
    errors.add(:publisher, "the owner has to be an publisher but is a #{publisher.class.name}") unless (publisher.is_a? Publisher)
  end

  def base_url_is_valid
    begin
      uri = URI.parse(base_url)
      check = %w( http https ).include?(uri.scheme) && !uri.path.blank?
    rescue
      check = false
    end
    errors.add(:base_url, "has to be a valid url") unless check
  end

end
