class Message < AdServeModel

  attribute :content
  has_many :user, :intevent
  
  validates :content, :format => {:with => /^[0-9a-zA-Z ]+$/},
                      :length => { :maximum => 1024 }
  
  validate :has_exactly_one_sender_and_one_recipient

  def sender
    user[0]
  end

  def sender= (sender)
    user[0] = sender
  end
 
  def recipient
    user[1]  
  end
 
  def recipient= (recipient)
    user[1] = recipient
  end
  
  def has_exactly_one_sender_and_one_recipient
    errors.add(:user, "Sender and recipient are needed!") if (user.length != 2)
  end
  
  def self.acceptApplication(message)
    answer = Message.new
    
    answer.sender = message.recipient
    answer.recipient = message.sender
    answer.content = message.content.dup
    
    intevent = Intevent.new

    intevent.ids = message.intevent[0].ids.dup
    intevent.event_type = EventType::ACCEPT_APPLICATION
    intevent.message = answer

    answer.intevent << intevent
    return answer
  end

  private :user

end
