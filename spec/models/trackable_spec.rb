require_relative '../spec_helper'

def trackableValue(trackable)
  case trackable
  when View
    1
  when Click
    2
  when Conversion
    3
  end
end

def compareTrackables(a, b)
  comp = trackableValue(a) - trackableValue(b)
  if (comp < 0)
    comp = -1
  elsif (comp > 0)
    comp = 1
  end
  return comp
end

describe Trackable do

  before do
    @trackable = Trackable.new
    @view1 = FactoryGirl.build(:view1)
    @view2 = FactoryGirl.build(:view2)
    @click1 = FactoryGirl.build(:click1)
    @click2 = FactoryGirl.build(:click2)
    @conversion1 = FactoryGirl.build(:conversion1)
    @conversion2 = FactoryGirl.build(:conversion2)
  end

  subject { @trackable }

  it { should respond_to :view }
  it { should respond_to :click }
  it { should respond_to :conversion }
  it { should respond_to :viewsCount }
  it { should respond_to :clicksCount }
  it { should respond_to :conversionsCount }
  it { should respond_to :eventsPerYear }
  it { should respond_to :eventsPerMonth }
  it { should respond_to :eventsPerDay }

  it { should be_valid }

  describe "when no view is added" do
    it { @trackable.viewsCount.should equal(0) }
  end
 
  describe "when no clicks is added" do
    it { @trackable.clicksCount.should equal(0) }
  end

  describe "when no conversions is added" do
    it { @trackable.conversionsCount.should equal(0) }
  end

  describe "when two views are added" do
    before do
      @trackable.view << @view1
      @trackable.view << @view2
    end
    it "should have an viewcount of two" do
      @trackable.viewsCount.should equal(2)
    end
  end
 
  describe "when two clicks are added" do
    before do
      @trackable.click << @click1
      @trackable.click << @click2
    end
    it "should have an clickcount of two" do
      @trackable.clicksCount.should equal(2)
    end
  end
 
  describe "when two conversions are added" do
    before do
      @trackable.conversion << @conversion1
      @trackable.conversion << @conversion2
    end
    it "should have an conversioncount of two" do
      @trackable.conversionsCount.should equal(2)
    end
  end
  
  describe "when several events are added" do
    before do
      @trackable.view << @view1
      @trackable.view << @view2
      @trackable.click << @click1
      @trackable.click << @click2
      @trackable.conversion << @conversion1
      @trackable.conversion << @conversion2
      
      @date = Date.new 2012,10,11
      @year = @date.year
      @month = @date.month
      @day = @date.day
    end
    
    it "should return several events for this year" do
      actual = @trackable.eventsPerYear(@year)
      actual.length.should equal(6)
      expected = [@view1, @view2, @click1, @click2, @conversion1, @conversion2]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true
    end
    
    it "should return several events for this month" do
      actual = @trackable.eventsPerMonth(@year, @month)
      actual.length.should equal(6)
      expected = [@view1, @view2, @click1, @click2, @conversion1, @conversion2]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true
    end
    
    it "should return several events for certain days" do
      actual = @trackable.eventsPerDay(@year, @month, @day) 
      actual.length.should equal(0)
      
      actual = @trackable.eventsPerDay(@year, @month, @day-1)
      actual.length.should equal(1)

      expected = [@click1]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true
 
      actual = @trackable.eventsPerDay(@year, @month, @day-2) 
      actual.length.should equal(1)

      expected = [@click2]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true

      actual = @trackable.eventsPerDay(@year, @month, @day-3) 
      actual.length.should equal(1)

      expected = [@view1]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true

      actual = @trackable.eventsPerDay(@year, @month, @day-4) 
      actual.length.should equal(1)

      expected = [@view2]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true

      actual = @trackable.eventsPerDay(@year, @month, @day-5) 
      actual.length.should equal(1)

      expected = [@conversion1]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true
      
      actual = @trackable.eventsPerDay(@year, @month, @day-6) 
      actual.length.should equal(1)

      expected = [@conversion2]
      (actual.uniq.sort {|a,b| compareTrackables(a, b)} == expected.uniq.sort {|a,b| compareTrackables(a, b)}).should be_true
    end
  end

end
