require_relative '../spec_helper'

describe Website do

  before(:all) do
    @couchbaseserver = TestCouchbaseServer.new
    @couchbaseserver.start
    @advertiser = FactoryGirl.create(:advertiser)
    @publisher = FactoryGirl.create(:publisher)
  end

  before(:each) do
    @website = FactoryGirl.build(:website)
    @website.publisher = @publisher
  end

  subject { @website }

  it { should respond_to :categories }
  it { should respond_to :zone }
  it { should respond_to :publisher }
  it { should respond_to :name }
  it { should respond_to :base_url}
  it { should respond_to :description }

  it { should be_valid }

  describe "when an advertiser owns a website" do
    before do
      @website.publisher = @advertiser
    end
    it { should_not be_valid }
  end

  describe "when owner_id is nil" do
    before { @website.publisher = nil }
    it {should_not be_valid }
  end

  describe "when base_url is not present" do
    before { @website.base_url = " " }
    it { should_not be_valid }
  end

  describe "when base_url is not valid" do
    before { @website.base_url = "lol" }
    it { should_not be_valid }
  end

  describe "when a valid website is saved"
    before {@website.save!}
    it { expect(Website.retrieve(@website.id) == @website)}
end
