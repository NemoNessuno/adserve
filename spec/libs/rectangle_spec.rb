require_relative '../spec_helper'

describe Rectangle do

  before { @rectangle = Rectangle.new(SpecConstants::TEST_RECTANGLE_WIDTH, SpecConstants::TEST_RECTANGLE_HEIGHT) }

  subject {@rectangle}
  
  describe "when a rectangle is initialized using integers" do
    it "should contain the data it was initialized with" do
      @rectangle.width.should equal(SpecConstants::TEST_RECTANGLE_WIDTH)
      @rectangle.height.should equal(SpecConstants::TEST_RECTANGLE_HEIGHT)
    end
  end
  
  describe "when rectangle is initialized using a string" do
    before {  @rectangle = Rectangle.fromString(SpecConstants::TEST_RECTANGLE_STRING) }
    it "should contain the comma seperated data" do
      @rectangle.width.should equal(SpecConstants::TEST_RECTANGLE_WIDTH)
      @rectangle.height.should equal(SpecConstants::TEST_RECTANGLE_HEIGHT)
    end
  end

  describe "when rectangle is initialized a negative width" do
    it "should raise an exception" do
      expect { Rectangle.new(-100, SpecConstants::TEST_RECTANGLE_HEIGHT) }.to raise_error
    end
  end

  describe "when rectangle is initialized a negative height" do
    it "should raise an exception" do
      expect { Rectangle.new(SpecConstants::TEST_RECTANGLE_WIDTH, -100) }.to raise_error
    end
  end

  describe "when rectangle is given a negative width" do
    it "should raise an exception" do
      expect { @rectangle.width = -100 }.to raise_error
    end
  end

  describe "when rectangle is given a negative height" do
    it "should raise an exception" do
      expect { @rectangle.height = -100 }.to raise_error
    end
  end

  describe "when rectangle is initialized using a string with negative numbers" do
    it "should raise an error" do
      expect { Rectangle.fromString("-100, -100")}.to raise_error
    end
  end

  describe "when rectangle is initialized using a invalid string" do
    it "should raise an error" do
      expect { Rectangle.fromString("-100, -100, 100")}.to raise_error
    end
  end

end
