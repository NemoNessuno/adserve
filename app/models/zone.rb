class Zone < Trackable 

  attribute :size
  belongs_to :website
  has_many :ad

  validate :is_size_valid
  
  def width 
    @rectangle ||= Rectangle.fromString(size)
    return @rectangle.width
  end

  def height 
    @rectangle ||= Rectangle.fromString(size)
    return @rectangle.height
  end
  
  def is_size_valid 
    begin
      Rectangle.fromString(self.size)
    rescue
      errors.add(:size, "Size has to be a string in the format: width, height. width and height being > 0.")
    end
  end

end
