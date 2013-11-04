require_relative '../spec_helper'


TEST_CAMPAIGN_COST_PER_AD = 1.11
TEST_CAMPAIGN_TOTAL_COST = 1.12

describe Campaign do

  before(:all) do
     @couchbaseserver = TestCouchbaseServer.new
     @couchbaseserver.start
     @advertiser = FactoryGirl.create(:advertiser)
     @publisher = FactoryGirl.create(:publisher)
    
  end

  before(:each) do 
    @campaign = FactoryGirl.build(:campaign)
    @campaign.advertiser = @advertiser
    @ad1 = FactoryGirl.build(:ad)
    @ad2 = FactoryGirl.build(:ad2)
    @ad3 = FactoryGirl.build(:ad3)
    @zone = FactoryGirl.build(:zone)
    @view1 = FactoryGirl.build(:view1)
    @view2 = FactoryGirl.build(:view2)
    @click1 = FactoryGirl.build(:click1)
    @click2 = FactoryGirl.build(:click2)
    @conversion1 = FactoryGirl.build(:conversion1)
    @conversion2 = FactoryGirl.build(:conversion2)
    @website = FactoryGirl.build(:website)
    @trackable = Trackable.new
    @advertiser.ad << @ad1
    @advertiser.ad << @ad2
    @advertiser.ad << @ad3
    @ad1.advertiser = @advertiser
    @ad2.advertiser = @advertiser
    @ad3.advertiser = @advertiser
    @ad1.view << @view1
    @ad3.view << @view2
    @ad1.click << @click1
    @ad2.click << @click2
    @ad1.conversion << @conversion1
    @ad2.conversion << @conversion2
    @zone.ad << @ad1
    @zone.ad << @ad2
    @zone.website = @website
    @website.zone << @zone
  end

  subject { @campaign }

  it { should respond_to :id }
  it { should respond_to :name }
  it { should respond_to :target_url}
  it { should respond_to :expiration_date }
  it { should respond_to :budget }
  it { should respond_to :billing_type }
  it { should respond_to :budget_type }
  it { should respond_to :ad }
  it { should respond_to :zone }
  it { should respond_to :cp_view }
  it { should respond_to :cp_click }
  it { should respond_to :cp_conversion }
  it { should respond_to :overallCost }
  it { should respond_to :costPerAd }
  it { should respond_to :costPerWebsite }
  it { should respond_to :costPerZone }
  
  it {should be_valid }

  describe "when a publisher owns a campaign" do
    before do
      @campaign.advertiser = @publisher
    end
    it { should_not be_valid }
  end

  describe "when publisher is nil" do
    before { @campaign.advertiser = nil }
    it {should_not be_valid }
  end

  describe "when expiration_date is invalid" do
    before { @campaign.expiration_date = "invalid" }
    it { should_not be_valid }
  end

  describe "when expiration_date is before today" do
    before { @campaign.expiration_date = (Date.today - 10).to_s}
    it { should_not be_valid }
  end

  describe "when name is not present" do
    before { @campaign.name = " " }
    it { should_not be_valid }
  end

  describe "when target_url is not present" do
    before { @campaign.target_url = " " }
    it { should_not be_valid }
  end

  describe "when target_url is not valid" do
    before { @campaign.target_url = "lol" }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @campaign.name = "a"*129 }
    it { should_not be_valid }
  end

  describe "when name is not non alphanumeric characters" do
    before { @campaign.name = "1234567890!\"" }
    it { should_not be_valid }
  end

  describe "when billing_type is not known too big" do
    before { @campaign.billing_type = 3 }
    it { should_not be_valid }
  end

  describe "when billing_type is not known too little" do
    before { @campaign.billing_type = 0 }
    it { should_not be_valid }
  end

  describe "when budget_type is not known too big" do
    before { @campaign.budget_type = 5 }
    it { should_not be_valid }
  end

  describe "when budget_type is not known too little" do
    before { @campaign.budget_type = 0 }
    it { should_not be_valid }
  end
  
  describe "When there are no ads" do
    it { expect(@campaign.costPerAd(@ad1)).to eq(0)}
  end
  
  describe "When there are no zones" do
    it "should have a zero cost per website and zero cost per zone" do
      expect(@campaign.costPerZone(@zone)).to eq(0)
      expect(@campaign.costPerWebsite(@website)).to eq(0)
    end
  end
  
  describe "When there are ads which got events" do
    before do
      @campaign.ad << @ad1
      @campaign.save!
    end
    it { expect(@campaign.costPerAd(@ad1)).to eq(TEST_CAMPAIGN_COST_PER_AD)}
    it { expect(@campaign.costPerAd(@ad2)).to eq(0)}
  end
  
  describe "When there are zones with ads that got events" do
    before do 
      @campaign.zone << @zone
      @campaign.ad << @ad1
      @campaign.ad << @ad3
      @campaign.save!
    end
    it { expect(@campaign.costPerZone(@zone)).to eq(TEST_CAMPAIGN_COST_PER_AD)} 
    it { expect(@campaign.costPerWebsite(@website)).to eq(TEST_CAMPAIGN_COST_PER_AD)}
    it { expect(@campaign.overallCost).to eq(TEST_CAMPAIGN_TOTAL_COST)}
  end

end
