# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

use Rack::MethodOverride

helpers do
  def convert_json_into_hash(params)
    @memo_info = File.open("datastrage/#{File.basename(params)}") do |file|
      JSON.parse(file.read)
    end
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @title = '一覧'
  file_names = Dir.glob('datastrage/*.json')
  @memos = file_names.map do |file_name|
    convert_json_into_hash(file_name)
  end
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos' do
  memo_title = params[:memo_title]
  article = params[:article]
  hash = { 'id' => SecureRandom.uuid, 'memo_title' => memo_title, 'article' => article }
  File.open("datastrage/memo.#{hash['id']}.json", 'w') do |file|
    file.puts JSON.pretty_generate(hash)
  end
  redirect to('/memos')
end

get '/memos/:id' do
  @title = '詳細'
  convert_json_into_hash(params[:id])
  erb :detail
end

get '/memos/:id/edit' do
  @title = '編集'
  convert_json_into_hash(params[:id])
  erb :edit
end

patch '/memos/:id' do
  hash = convert_json_into_hash(params[:id])
  hash['memo_title'] = params[:memo_title]
  hash['article'] = params[:article]
  File.open("datastrage/#{params[:id]}", 'w') do |file|
    JSON.dump(hash, file)
  end
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  File.delete("datastrage/#{params[:id]}")
  redirect to('/memos')
end
