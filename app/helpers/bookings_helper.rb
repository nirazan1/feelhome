module BookingsHelper
  def formatted_duration(total_minute)
    hours = total_minute.to_i / 60
    minutes = (total_minute.to_i) % 60
    "#{ hours } Hrs #{ minutes } Min"
  end
end
