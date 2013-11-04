class User < AdServeModel
  require 'pbkdf2'
  require 'date'
  
  has_many :message

  attribute :name, :surname, :email, :password_hash, :password_salt
  attr_accessor :password, :password_confirmation, :type

  attribute :user_since, :default => lambda{ Date.today.to_s }
  
  validates :name,     :presence => true,
                       :format => {:with => /^[0-9a-zA-Z ]+$/},
                       :length => { :minimum => 1, :maximum => 128 }
                       
  validates :surname,  :presence => true,                       
                       :format => {:with => /^[0-9a-zA-Z ]+$/},
                       :length => { :minimum => 1, :maximum => 128 }

  validates :email, :presence => true                     
  validates_format_of :email, :with => /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  validate :password_on_create

  before_create :prepare_to_create

  def full_name
    [self.name, self.surname].join(', ')
  end

  def self.authenticate(email, password)
    begin
      id = bucket.get("email::#{email.to_s}".downcase)

      return nil if id.nil?

      user = find(id)
      return nil if user.nil?

      password = PBKDF2.new do |p|
        p.password = password
        p.salt = user.password_salt
        p.iterations = 5000
      end

      if user && (user.password_hash) == password.hex_string
        return user
      else
        return nil
      end

    #rescue
    #  return nil
    end
  end

  def self.find(id)
    return convert_user(bucket.get(id), id)
  end

  def self.convert_user(user, id)
    case user["type"]
    when "advertiser"
      return Advertiser.find_by_id(id)
    when "publisher"
      return Publisher.find_by_id(id)
    when "admin"
      return Admin.find_by_id(id)
    else
      raise "Unknown user type"
    end
  end 
  
  #TODO: Delete auch associations
  #deletes this user
  def delete()
    return User.bucket.delete("email::#{self.email.downcase}") && User.bucket.delete(@id)
  end

  def encrypt_password
    if self.password.present?
      hashedpassword = create_password(self.password)
      self.password_hash = hashedpassword.hex_string
      self.password_salt = hashedpassword.salt
    end
  end

  #Creates a new PBKDF2 instance with the given string
  #and the given salt. If no salt is specified
  # a SecureRandom.base(16) string is used
  def create_password(pwString, saltString = SecureRandom.urlsafe_base64(16))
    password = PBKDF2.new do |p|
      p.password = pwString
      p.salt = saltString
      p.iterations = 5000
    end
  end

  #todo: make sure no 500 happens when an email already exists!
  def prepare_to_create
    if (valid?)
      encrypt_password
    end
  end
  
  #Overrides the default ID creation of the AdServeModel
  def createID
    if (valid?)
      id = User.bucket.incr("user_key", 1, :initial => 1).to_s
      User.bucket.add("email::#{self.email.downcase}", id)
      return id
    end
    return nil
  end

  def self.user_key
    begin
      return User.bucket.get("user_key")
    rescue
      return 0
    end
  end

  def password_on_create
    return if persisted?

    errors.add(:password, "Password must not be blank!") if (password.blank?)
    errors.add(:password, "Password must be longer than 6 characters!") if (password.length < 6)
    errors.add(:password, "Password must not be longer than 32 characters!") if (password.length > 32)
    errors.add(:password, "Password must equal password confirmation") if (password != password_confirmation)
  end
end
