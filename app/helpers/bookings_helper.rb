module BookingsHelper
  def formatted_duration(total_minute)
    hours = total_minute.to_i / 60
    minutes = (total_minute.to_i) % 60
    "#{ hours } Hrs #{ minutes } Min"
  end

  def flight_detail(trip_data, segment)
    # (MH-115) Malaysia Airlines (738) Boeing 737
    # (segment[:flight][:carrier]-segment[:flight][:number]) data[:carrier][:name] (leg[:aircraft]) data[:aircraft][:name]
    "#{carrier_name(trip_data, segment)} "\
    "(#{segment["flight"]["carrier"]}-#{segment["flight"]["number"]}) "
  end

  def aircraft_detail(trip_data, leg)
    "#{aircraft_name(trip_data, leg)} (#{leg[:aircraft]})"
  end

  def aircraft_name(trip_data, leg)
    trip_data[:aircraft].select {|aircraft| aircraft[:code] == leg[:aircraft] }.last&.dig(:name)
  end

  def carrier_name(trip_data, segment)
    trip_data[:carrier].select {|carrier| carrier[:code] == segment["flight"]["carrier"] }.last&.dig(:name)
  end

  def location_detail(trip_data, location)
    "#{airport_detail(trip_data, location)} Airport, #{trip_data[:city].select {|city| city[:code] == location }.last&.dig(:name)} (#{location})"
  end

  def airport_detail(trip_data, location)
    "#{trip_data[:airport].select {|airport| airport[:code] == location }.last&.dig(:name)}"
  end
end
