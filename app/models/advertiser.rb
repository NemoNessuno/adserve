class Advertiser < User

  #TODO: Account Information (i.e. how to pay for stuff?)  

  has_many :campaign, :ad
  
end
