require_relative '../spec_helper'
#TODO: more testcases. also negative ones
include Query
describe "Apply for a Campaign" do
 
  def logIn
    visit log_in_path
    fill_in "_sessions_email", with: SpecConstants::TEST_PUBLISHER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_PUBLISHER_PASSWORD
    click_button "Log In"
  end
  
  def click_find_campaign
    page.find_link("Find Campaigns").click
  end
  
  def click_details
    page.find_link("Details").click
  end

  def check_if_campaigns_are_listed
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_NAME)
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_CP_VIEW)
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_CP_CLICK)
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_CP_CONVERSION)
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_EXPIRATION_DATE)
  end

  subject {page}
  
  let(:search)  {"Search Campaign"}
  let(:apply)   {"Apply"}

  describe "Apply for a campaign" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @advertiser = FactoryGirl.create(:advertiser)
      @campaign = FactoryGirl.build(:campaign)
      @ad = FactoryGirl.build(:ad)
      
      @ad.advertiser = @advertiser
      @advertiser.ad << @ad

      @ad.save!
      
      @advertiser.campaign << @campaign
      @campaign.advertiser = @advertiser
      @campaign.ad << @ad

      @campaign.save!

      @publisher = FactoryGirl.create(:publisher)
      @website = FactoryGirl.build(:website)
      @zone = FactoryGirl.build(:zone)

      @publisher.website << @website
      @website.publisher = @publisher
      
      @website.zone << @zone
      @zone.website = @website

      @website.save!
      
      i = 0
      while getCampaigns.empty?
        i += 1
        sleep(0.4)
        i.should be < 10
      end
      campaigns = getCampaigns
      campaigns.empty?.should_not be_true
    end
  
    before(:each) do
      logIn
    end

    it "should be possible to find a campaign and apply for it",:js => true do
      expect{click_find_campaign}.to change{page.current_path}.from(publishers_home_path).to(publishers_find_campaigns_path)
      expect{click_button search}.not_to change{page.current_path}
      check_if_campaigns_are_listed
      expect{click_details}.to change{page.current_path}.from(publishers_find_campaigns_path).to(publishers_show_campaign_path)
    end
  end
end
