require_relative '../spec_helper'

describe Event do

  before do
    @event = FactoryGirl.build(:event)
  end

  subject { @event}

  it { should respond_to :event_date }
  it { should respond_to :target_id }

  it { should be_valid }

  describe "when event_date is not a date" do
    before { @event.event_date = "a" }
    it { should_not be_valid }
  end

  describe "when event_date is nil" do
    before { @event.event_date = nil }
    it { should_not be_valid }
  end

  describe "when event_date is in the future" do
    before { @event.event_date = (Date.today+1).to_s }
    it { should_not be_valid }
  end

  describe "when target_id is nil" do
    before { @event.target_id = nil }
    it { should_not be_valid }
  end

end
