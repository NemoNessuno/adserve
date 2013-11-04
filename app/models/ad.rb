class Ad < Trackable 

  #Content Types? How to ensure the validity of a certain content type? (image?)
  attribute :size, :content
  attr_accessor :width, :height
  belongs_to :advertiser
  
  validates :content, :presence => :true

  validate :is_size_valid

  def is_size_valid 
    begin
      Rectangle.fromString(self.size)
    rescue
      errors.add(:size, "Size has to be a string in the format: width; height. width and height being > 0.")
    end
  end

end
