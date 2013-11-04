require 'factory_girl_rails'
require 'date'

class SpecConstants

  #String Constants
  TEST_PUBLISHER_NAME = "TestPublisherName"
  TEST_PUBLISHER_SURNAME = "TestPublisherSurname"
  TEST_PUBLISHER_EMAIL = "TestPublisher@test.test"
  TEST_PUBLISHER_PASSWORD = "TestPublisherPassword"

  TEST_ADVERTISER_NAME = "TestAdvertiserName"
  TEST_ADVERTISER_SURNAME = "TestAdvertiserSurname"
  TEST_ADVERTISER_EMAIL = "TestAdvertiser@test.test"
  TEST_ADVERTISER_PASSWORD = "TestAdvertiserPassword"

  TEST_USER_NAME = "TestUserName"
  TEST_USER_SURNAME = "TestUserSurname"
  TEST_USER_EMAIL = "TestUser@test.test"
  TEST_USER_PASSWORD = "TestUserPassword"

  TEST_CAMPAIGN_NAME = "TestCampaignName"
  TEST_CAMPAIGN_EXPIRATION_DATE = (Date.today + 30).to_s
  TEST_CAMPAIGN_TARGET_URL = "http://localhost:8055/testpwebsite"
  TEST_CAMPAIGN_BUDGET = 1000
  TEST_CAMPAIGN_BILLING_TYPE = BillingType::DIRECT_DEBIT
  TEST_CAMPAIGN_BUDGET_TYPE = BudgetType::TOTAL
  TEST_CAMPAIGN_CP_VIEW = 0.01
  TEST_CAMPAIGN_CP_CLICK = 0.1
  TEST_CAMPAIGN_CP_CONVERSION = 1

  TEST_RECTANGLE_WIDTH = 100
  TEST_RECTANGLE_HEIGHT = 50
  TEST_RECTANGLE_STRING = "#{TEST_RECTANGLE_WIDTH}; #{TEST_RECTANGLE_HEIGHT}"

  TEST_AD_SIZE = TEST_RECTANGLE_STRING
  TEST_AD_1_CONTENT = "TestAd1Content"
  TEST_AD_2_CONTENT = "TestAd2Content"
  TEST_AD_3_CONTENT = "TestAd3Content"
  
  TEST_ZONE_SIZE = TEST_RECTANGLE_STRING

  TEST_TARGET_ID = "sdlfkjb3247z23sd"
  TEST_EVENT_DATE = Date.today.to_s

  TEST_CLICK_1_TARGET_ID = "dfuhw34lkdsfkjh324"
  TEST_CLICK_1_EVENT_DATE = (Date.new(2012,10,10)).to_s
  
  TEST_CLICK_2_TARGET_ID = "sflkjn324lökn32iu4"
  TEST_CLICK_2_EVENT_DATE = (Date.new(2012,10,9)).to_s
 
  TEST_VIEW_1_TARGET_ID = "w4k32h4oijtoi43j5i"
  TEST_VIEW_1_EVENT_DATE = (Date.new(2012,10,8)).to_s
  
  TEST_VIEW_2_TARGET_ID = "dflkejrnt43k5wkjn2"
  TEST_VIEW_2_EVENT_DATE = (Date.new(2012,10,7)).to_s

  TEST_CONVERSION_1_TARGET_ID = "234newfu3n4ipuhesd"
  TEST_CONVERSION_1_EVENT_DATE = (Date.new(2012,10,6)).to_s
  
  TEST_CONVERSION_2_TARGET_ID = "32krnerun324iuh324"
  TEST_CONVERSION_2_EVENT_DATE = (Date.new(2012,10,5)).to_s

  TEST_CATEGORY_1 = "TestCategory1"
  TEST_CATEGORY_2 = "TestCategory2"
  TEST_CATEGORY_3 = "TestCategory3"

  TEST_WEBSITE_NAME = "TestWebSiteName"
  TEST_WEBSITE_BASE_URL = "http://localhost:8055/testadwebsite"
  TEST_WEBSITE_DESCRIPTION = "TestWebSiteDescription"

  TEST_MESSAGE_CONTENT = "CONTENT"

  TEST_INTEVENT_TYPE = EventType::APPLICATION

  #Factory definitions
  FactoryGirl.define do
    factory :publisher, class: Publisher do
      name TEST_PUBLISHER_NAME
      surname TEST_PUBLISHER_SURNAME
      email TEST_PUBLISHER_EMAIL
      password TEST_PUBLISHER_PASSWORD
      password_confirmation TEST_PUBLISHER_PASSWORD
    end

    factory :advertiser, class: Advertiser do
      name TEST_ADVERTISER_NAME
      surname TEST_ADVERTISER_SURNAME
      email TEST_ADVERTISER_EMAIL
      password TEST_ADVERTISER_PASSWORD
      password_confirmation TEST_ADVERTISER_PASSWORD
    end

    factory :user, class: User do
      name TEST_USER_NAME
      surname TEST_USER_SURNAME
      email TEST_USER_EMAIL
      password TEST_USER_PASSWORD
      password_confirmation TEST_USER_PASSWORD
    end

    factory :campaign do
      name TEST_CAMPAIGN_NAME
      target_url TEST_CAMPAIGN_TARGET_URL
      expiration_date TEST_CAMPAIGN_EXPIRATION_DATE
      budget TEST_CAMPAIGN_BUDGET
      billing_type TEST_CAMPAIGN_BILLING_TYPE
      budget_type TEST_CAMPAIGN_BUDGET_TYPE
      cp_view TEST_CAMPAIGN_CP_VIEW
      cp_click TEST_CAMPAIGN_CP_CLICK
      cp_conversion TEST_CAMPAIGN_CP_CONVERSION
    end

    factory :event do
      event_date TEST_EVENT_DATE
      target_id TEST_TARGET_ID
    end
    
    factory :click1, class: Click do
      event_date TEST_CLICK_1_EVENT_DATE
      target_id TEST_CLICK_1_TARGET_ID
    end

    factory :click2, class: Click do
      event_date TEST_CLICK_2_EVENT_DATE
      target_id TEST_CLICK_2_TARGET_ID
    end

    factory :view1, class: View do
      event_date TEST_VIEW_1_EVENT_DATE
      target_id TEST_VIEW_1_TARGET_ID
    end

    factory :view2, class: View do
      event_date TEST_VIEW_2_EVENT_DATE
      target_id TEST_VIEW_2_TARGET_ID
    end

    factory :conversion1, class: Conversion do
      event_date TEST_CONVERSION_1_EVENT_DATE
      target_id TEST_CONVERSION_1_TARGET_ID
    end

    factory :conversion2, class: Conversion do
      event_date TEST_CONVERSION_2_EVENT_DATE
      target_id TEST_CONVERSION_2_TARGET_ID
    end

    factory :ad do
      size TEST_AD_SIZE
      content TEST_AD_1_CONTENT
    end
    
    factory :ad2, class: Ad do
      size TEST_AD_SIZE
      content TEST_AD_2_CONTENT
    end
    
    factory :ad3, class: Ad do
      size TEST_AD_SIZE
      content TEST_AD_3_CONTENT
    end

    factory :zone do
      size TEST_ZONE_SIZE
    end

    factory :website do
      name  TEST_WEBSITE_NAME
      base_url TEST_WEBSITE_BASE_URL
      description  TEST_WEBSITE_DESCRIPTION
      categories TEST_CATEGORY_1
    end

    factory :message do
      content TEST_MESSAGE_CONTENT
    end
    
    factory :intevent do
      event_type TEST_INTEVENT_TYPE
    end
  end
end

class TestAdServeModel1 < AdServeModel
  attribute :test_attribute
  validates :test_attribute,     :presence => true
  has_many  :testAdServeModel2,  :testAdServeModel3
end

class TestAdServeModel2 < AdServeModel
  belongs_to :testAdServeModel1
  has_many   :testAdServeModel3, :testAdServeModel5
end

class TestAdServeModel3 < AdServeModel
  belongs_to :testAdServeModel1, :testAdServeModel2
end

class TestAdServeModel4 < AdServeModel
  belongs_to :testAdServeModel5
  has_many :testAdServeModel6
end

class TestAdServeModel5 < AdServeModel
  belongs_to :testAdServeModel2
  attribute :test_attribute
  validates :test_attribute,    :presence => true
end

class TestAdServeModel6 < AdServeModel
end

class TestAdServeModel7 < TestAdServeModel4
  has_many :testAdServeModel3
end

class TestAdServeModel8 < TestAdServeModel7; end

class TestAdServeModel9 < AdServeModel
  has_many :testAdServeModel11
end

class TestAdServeModel10 < AdServeModel
  has_many :testAdServeModel6
end

class TestAdServeModel11 < AdServeModel
  belongs_to :testAdServeModel9
  has_many   :testAdServeModel12
end

class TestAdServeModel12 < TestAdServeModel10
  has_many :testAdServeModel13
end

class TestAdServeModel13 < TestAdServeModel10
  belongs_to :testAdServeModel12
end
