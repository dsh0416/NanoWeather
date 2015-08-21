require 'sinatra'

get '/:time' do |time|
  time
end

get '/' do
  erb :index
end