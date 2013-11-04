require 'date'

class Campaign < AdServeModel
  
  attribute :name, :target_url,
            :expiration_date,:categories, 
            :billing_type, :budget, :budget_type,
            :cp_click, :cp_view, :cp_conversion
  
  belongs_to :advertiser
  has_many :ad, :zone

  #Owner validations
  validate :owner_exists_and_is_an_advertiser
  
  #date validations
  validate :expiration_date_is_valid
 
  validate :target_url_is_valid

  validates :target_url,  :presence => true
  validates :name,     :presence => true,
    :format => {:with => /^[0-9a-zA-Z ]+$/},
    :length => { :minimum => 1, :maximum => 128 }
  validates :expiration_date, :presence => true
  validates :billing_type, :numericality => {:greater_than => 0, :less_than => 3}
  validates :budget_type, :numericality => {:greater_than => 0, :less_than => 5}
  validates :cp_click, :numericality => {:greater_than_or_equal => 0}
  validates :cp_view, :numericality => {:greater_than_or_equal => 0}
  validates :cp_conversion, :numericality => {:greater_than_or_equal => 0}
  
  def billing_type=(val)
    write_attribute :billing_type, val.to_i
  end

  def budget=(val)
    write_attribute :budget, val.to_i
  end
  
  def budget_type=(val)
    write_attribute :budget_type, val.to_i
  end

  def cp_click=(val)
    write_attribute :cp_click, val.to_f
  end

  def cp_view=(val)
    write_attribute :cp_view, val.to_f
  end

  def cp_conversion=(val)
    write_attribute :cp_conversion, val.to_f
  end

  def overallCost
    ad.inject(0) {|sum, a| sum + costPerAd(a)}
  end
  
  def costPerWebsite(website)
    website.zone.inject(0) {|sum, z| sum + costPerZone(z)}
  end
  
  def costPerAd(look_up_ad)
    loc_ad = (ad.select {|a| look_up_ad.id == a.id}).first

    return 0 if loc_ad.nil?
    sum =  loc_ad.viewsCount * cp_view
    sum += loc_ad.clicksCount * cp_click
    sum += loc_ad.conversionsCount * cp_conversion
    return sum
  end
  
  def costPerZone(look_up_zone)
    loc_zone = (zone.select {|z| look_up_zone.id == z.id}).first

    return 0 if loc_zone.nil?
    loc_zone.ad.inject(0) { |sum, a| sum + costPerAd(a)}
  end

  def expiration_date_is_valid
    begin
      parsedDate = Date.parse(expiration_date)
      if (!parsedDate.blank? and parsedDate < Date.today)
        errors.add(:expiration_date, "can't be in the past")
      end
    rescue
      errors.add(:expiration_date, 'must be a valid datetime')
    end
  end
 
  def owner_exists_and_is_an_advertiser
    errors.add(:advertiser, "the owner has to be an advertiser") unless (advertiser.is_a? Advertiser)
  end
  
  def target_url_is_valid
    begin
      uri = URI.parse(target_url)
      check = %w( http https ).include?(uri.scheme) && !uri.path.blank?
    rescue    
      check = false
    end
    errors.add(:target_url, "has to be a valid url") unless check
  end
end
