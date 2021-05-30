# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

use Rack::MethodOverride

get '/memos' do
  file_names = Dir.glob('*.json')
  @names = file_names.map do |file_name|
    File.open(file_name.to_s) do |file|
      JSON.parse(file.read)
    end
  end
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos/new' do
  @memo_title = params[:memo_title]
  @article = params[:article]
  hash = { 'id' => SecureRandom.uuid, 'memo_title' => @memo_title, 'article' => @article }
  File.open("memo.#{hash['id']}.json", 'w') do |file|
    file.puts JSON.pretty_generate(hash)
  end
  redirect to('/memos')
end

get '/memos/:id' do
  elements = File.open(params[:id].to_s) do |file|
    JSON.parse(file.read)
  end
  @memo_title = elements['memo_title']
  @article = elements['article']
  @id = elements['id']
  erb :detail
end

get '/memos/:id/edit' do
  @elements = File.open(params[:id].to_s) do |file|
    JSON.parse(file.read)
  end
  erb :edit
end

patch '/memos/:id' do
  hash = File.open(params[:id].to_s) do |file|
    JSON.parse(file.read)
  end
  hash['memo_title'] = params[:memo_title]
  hash['article'] = params[:article]
  File.open(params[:id].to_s, 'w') do |file|
    JSON.dump(hash, file)
  end
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  File.delete(params[:id].to_s)
  redirect to('/memos')
end
