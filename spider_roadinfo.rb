require 'net/http'
require 'json'
require 'mongo'
require 'bson'

db = Mongo::Client.new('mongodb://hacker:hacker@localhost:27017/admin')
collection = db['vd_info']

uri = URI('http://data.taipei/opendata/datalist/apiAccess')
params = {:scope => 'resourceAquire', :rid => '5aacba65-afda-4ad5-88f5-6026934140e6'}

while true

  begin
    now_time = Time.now.to_i
    uri.query = URI.encode_www_form(params)
    result = Net::HTTP.get_response(uri)
    data = JSON.parse(result.body)

    data['result']['results'].each do |sensor|
      row = {time:now_time,SessionId:sensor['SectionId'],AvgSpd:sensor['AvgSpd'],AvgOcc:sensor['AvgOcc']}
      collection.insert_one(row)
    end
    puts "Fetch Sucess Time:#{now_time}"
  rescue
    puts 'Error Fetching Data'
  end

  # Fetch Data Every 5 minutes
  sleep 305
end