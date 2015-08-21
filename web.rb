require 'sinatra'
require 'json'
require 'mongo'

get '/:time' do |time|
  time
end

get '/' do
  erb :index
end