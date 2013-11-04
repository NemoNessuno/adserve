require_relative '../spec_helper'

describe Intevent do

  before(:all) do
    TestCouchbaseServer.new.start
    @advertiser = FactoryGirl.create(:advertiser)
 end

  before(:each) do
    @publisher = FactoryGirl.build(:publisher)
    @message = FactoryGirl.build(:message)
    @intevent = FactoryGirl.build(:intevent)
    @message.sender = @advertiser
    @message.recipient = @publisher
    @advertiser.message.clear
    @advertiser.message << @message
    @intevent.message = @message
    @intevent.ids << @advertiser.id
    @message.intevent << @intevent
  end

  subject { @intevent }

  it { should respond_to :message}
  it { should respond_to :id}
  it { should respond_to :event_type}

  it { should be_valid }

  describe "when the event_type is too little" do
    before { @intevent.event_type = -1 } 
    it { should_not be_valid } 
  end

  describe "when the event_type is too big" do
    before { @intevent.event_type = 5 } 
    it { should_not be_valid } 
  end

  describe "when the id is not in the database" do
    before { @intevent.ids << "a" } 
    it { should_not be_valid } 
  end
end
