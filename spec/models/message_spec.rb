require_relative '../spec_helper'
# Test answer application
include Query

describe Message do

  before(:all) do
    TestCouchbaseServer.new.start
    @advertiser = FactoryGirl.create(:advertiser)
    @publisher = FactoryGirl.create(:publisher)
    @message = FactoryGirl.build(:message)
    @intevent = FactoryGirl.build(:intevent)
    @intevent.message = @message
    @message.intevent << @intevent
    @advertiser.message << @message
  end
  
  before(:each) do
    @message.sender = @advertiser
    @message.recipient = @publisher
  end

  subject { @message }

  it { should respond_to :sender}
  it { should respond_to :sender=}
  it { should respond_to :recipient}
  it { should respond_to :recipient=}
  it { should respond_to :content}

  it { should be_valid }

  describe "when content is empty" do 
    before { @message.content = " " } 
    it { should be_valid } 
  end 

  describe "when content is nonexistant" do 
    before { @message.content = "" } 
    it { should_not be_valid } 
  end 

  describe "when content contains wong characters" do 
    before { @message.content = "\\" } 
    it { should_not be_valid } 
  end 

  describe "when content is too long" do 
    before { @message.content = "a"*1025 } 
    it { should_not be_valid } 
  end 
  
  describe "when there is no sender attached" do 
    before { @message.sender = nil } 
    it { should_not be_valid } 
  end

  describe "when there is no recipient attached" do 
    before { @message.recipient = nil } 
    it { should_not be_valid } 
  end

  describe "when the message is saved" do 
    before do
      @message.content = SpecConstants::TEST_MESSAGE_CONTENT
      @message.save 
    end
    it "should equal the original one" do
      actual = Message.retrieve(@message.id)
      expect(actual.sender).to eq(@message.sender)
      expect(actual.recipient).to eq(@message.recipient)
      expect(actual.content).to eq(@message.content)
      expect(actual).to eq(@message)
      expect(actual.intevent[0].shallow_eq(@message.intevent[0])).to be_true
    end
  end
end
