require_relative '../spec_helper'

describe Publisher do

  before do
    @advertiser  = FactoryGirl.build(:advertiser)
    @publisher   = FactoryGirl.build(:publisher)
    @website1    = FactoryGirl.build(:website)
    @zone        = FactoryGirl.build(:zone)
    @ad          = FactoryGirl.build(:ad)
    @click1      = FactoryGirl.build(:click1)
    @view1       = FactoryGirl.build(:view1)
    @conversion1 = FactoryGirl.build(:conversion1)

    @ad.click        << @click1
    @ad.view         << @view1
    @ad.conversion   << @conversion1
    @zone.click      << @click1
    @zone.view       << @view1
    @zone.conversion << @conversion1

  end

  subject { @publisher }

  it { should respond_to(:id)}
  it { should respond_to(:name)}
  it { should respond_to(:surname)}
  it { should respond_to(:email)}
  it { should respond_to(:type)}
  it { should respond_to(:full_name)}
  it { should respond_to(:website)}
  it { should respond_to(:password_hash)}
  it { should respond_to(:user_since)}
  it { should respond_to(:password_salt)}
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:password)}

  it { should be_valid }

  describe "When a website added and the Publisher is saved." do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @publisher.website << @website1
      @website1.zone << @zone
      @advertiser.ad << @ad
      @ad.advertiser = @advertiser
      @zone.ad << @ad
      @zone.website = @website1

      @saved = @publisher.save
    end
    it "Should be possible to retrieve it" do
      @publisher.should_not be_valid
      @website1.should_not  be_valid
      @saved.should  be_false
       
      @website1.publisher = @publisher
      @saved = @publisher.save!

      @publisher.should be_valid
      @website1.should  be_valid

      actual = Publisher.retrieve(@publisher.id)
      expect(actual.website[0].id).to eq(@website1.id)
      expect(actual.website[0].categories).to eq(@website1.categories)
      expect(actual.website[0].zone).to eq(@website1.zone)
      expect(actual.website[0].publisher).to eq(@publisher)
    end
  end

end
