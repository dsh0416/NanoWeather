require 'net/http'
require 'json'
require 'mongo'
require 'bson'

db = Mongo::Client.new('mongodb://hacker:hacker@localhost:27017/admin')
collection = db['sensor_info']

uri = URI('http://data.taipei/opendata/datalist/apiAccess')
params = {:scope => 'resourceAquire', :rid => '5aacba65-afda-4ad5-88f5-6026934140e6'}

uri.query = URI.encode_www_form(params)
result = Net::HTTP.get_response(uri)

data = JSON.parse(result.body)

data['result']['results'].each do |sensor|
  # puts "id = #{sensor['_id']} AvgSpd = #{sensor['AvgSpd']} AvgOcc = #{sensor['AvgOcc']}"
  row = {SessionId:sensor['SectionId'],StartWgsX:sensor['StartWgsX'],StartWgsY:sensor['StartWgsY'],EndWgsX:sensor['EndWgsX'],EndWgsY:sensor['EndWgsY'] }
  collection.insert_one(row)
end