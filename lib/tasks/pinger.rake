desc "This task is called by the Heroku scheduler add-on"
task :nepsepinger => :environment do
  puts "Pinging nepseStocks backend..."
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  base_url = "https://nepsestocks.herokuapp.com/users/sign_in"
  page = Nokogiri::HTML(open(base_url))
  puts "done."
end
