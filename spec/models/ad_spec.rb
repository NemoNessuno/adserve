require_relative '../spec_helper'

describe Ad do

  before(:all) do
    TestCouchbaseServer.new.start
    @advertiser = FactoryGirl.create(:advertiser)
    @ad = FactoryGirl.build(:ad)
    @ad.advertiser = @advertiser
    @advertiser.ad << @ad
  end

  subject { @ad }

  it { should respond_to :advertiser }
  it { should respond_to :size }
  it { should respond_to :view }
  it { should respond_to :click }
  it { should respond_to :conversion }
  it { should respond_to :content }

  it { should be_valid }

  describe "when size has an invalid format" do
    before { @ad.size = "asd" }
    it { should_not be_valid }
  end
  
  describe "when size has more than two values" do
    before { @ad.size = "100,100,100" }
    it { should_not be_valid }
  end

  describe "when size has less than two values" do
    before { @ad.size = "100" }
    it { should_not be_valid }
  end
  
  describe "when size has negative values" do
    before { @ad.size = "-100,-50" }
    it { should_not be_valid }
  end

end
