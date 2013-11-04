class Rectangle

  def width
    return @width
  end

  def height
    return @height
  end

  def width=(int)
    if (int <= 0)
      raise ArgumentException, "The Argument must be geq 0!"
    end
    @width = int
  end

  def height=(int)
    if (int <= 0)
      raise ArgumentException, "The Argument must be geq 0!"
    end
    @height = int
  end

  def initialize(width, height)
    self.width = width
    self.height = height
  end

  def Rectangle.fromString(valueString)
    values = valueString.split(";")

    if values.count != 2
      raise ArgumentException, "The argument had the wrong format! Needs to be: width; height"
    end
    
    return self.new(values[0].to_i, values[1].to_i)
  end

end
