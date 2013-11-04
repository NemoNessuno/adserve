class View < Event; end 
class Click < Event; end 
class Conversion < Event; end

class Trackable < AdServeModel 

  has_many :view, :click, :conversion
  
  def viewsCount
    view.length
  end
  
  def clicksCount
    click.length
  end

  def conversionsCount
    conversion.length
  end
  
  def eventsPerYear(year)
    all_events.select do |event|
      event.parsedDate.year == year
    end
  end
  
  def eventsPerMonth(year, month)
    all_events.select do |event|
      event.parsedDate.year == year and event.parsedDate.month == month
    end
  end
 
  def eventsPerDay(year, month, day)
    all_events.select do |event|
      event.parsedDate.year == year and event.parsedDate.month == month and event.parsedDate.day == day
    end
  end

  def all_events
   result = []
   result.concat view
   result.concat click
   result.concat conversion
  end

end
