require_relative '../spec_helper'

describe Advertiser do

  before do
    @advertiser = FactoryGirl.build(:advertiser)
    @campaign1  = FactoryGirl.build(:campaign)
  end

  subject { @advertiser }

  it { should respond_to(:id)}
  it { should respond_to(:name)}
  it { should respond_to(:surname)}
  it { should respond_to(:email)}
  it { should respond_to(:type)}
  it { should respond_to(:full_name)}
  it { should respond_to(:campaign)}
  it { should respond_to(:password_hash)}
  it { should respond_to(:user_since)}
  it { should respond_to(:password_salt)}
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:password)}

  it { should be_valid }

  describe "When a campaign added and the Advertiser is safed." do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @advertiser.campaign << @campaign1

      @saved = @advertiser.save
    end
    it "Should be possible to retrieve it" do
      @advertiser.should_not be_valid
      @campaign1.should_not  be_valid
      @saved.should  be_false
       
      @campaign1.advertiser = @advertiser
      @saved = @advertiser.save

      @advertiser.should be_valid
      @campaign1.should  be_valid
      @saved.should_not  be_false

      actual = Advertiser.retrieve(@advertiser.id)
      expect(actual.campaign[0].id).to eq(@campaign1.id)
      expect(actual.campaign[0].expiration_date).to eq(@campaign1.expiration_date)
      expect(actual.campaign[0].budget).to eq(@campaign1.budget)
      expect(actual.campaign[0].billing_type).to eq(@campaign1.billing_type)
      expect(actual.campaign[0].budget_type).to eq(@campaign1.budget_type)
      expect(actual.campaign[0].overallCost).to eq(@campaign1.overallCost)
    end
  end

end
