# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

use Rack::MethodOverride

conn = PG.connect( dbname: 'sinatra_memo_db' , user: "eatplaynap" )

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
  @memos = conn.exec( "SELECT * FROM memo" )
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.exec("INSERT INTO memo(memo_title, article)
    VALUES('#{memo_title}', '#{article}')")
  redirect to('/memos')
end

get '/memos/:id' do
  @title = '詳細'

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
