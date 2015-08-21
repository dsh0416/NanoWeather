require 'sinatra'
require 'json'
require 'mongo'

get '/:time' do |time|
  time
end

get '/' do
  db = Mongo::Client.new('mongodb://hacker:hacker@localhost:27017/admin')
  collection_vd = db['vd_info']
  collection_sensor = db['sensor_info']

  collection_vd.find.to_a.each do |sensor|
    collection_sensor.find(SessionId:sensor['SessionId']).sort(time:-1).to_a.each do ||

    end
  end

=begin
  collection_sentences.find(processed:false).limit(1).to_a.each do |row|
    sentence = sentence + row['sentence'] + "\n"
    row2 = row
    row2['processed'] = true
    collection_sentences.find(sentence:row['sentence'],_id:row['_id']).limit(1).update_one(row2)
  end


=end

  erb :index
end