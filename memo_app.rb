# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'
require 'pg'

use Rack::MethodOverride

conn = PG.connect( dbname: 'sinatra_memo_db' , user: "eatplaynap" )

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @title = '一覧'
  @memos = conn.exec( "SELECT * FROM memo ORDER BY id" )
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
  @memo_info = conn.exec( "SELECT * FROM memo WHERE id = #{params[:id]}" )
  erb :detail
end

get '/memos/:id/edit' do
  @title = '編集'
  @memo_info = conn.exec( "SELECT * FROM memo WHERE id = #{params[:id]}" )
  erb :edit
end

patch '/memos/:id' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.exec( "UPDATE memo
  SET memo_title = '#{memo_title}',
      article = '#{article}'
    WHERE id =  #{params[:id]} " )
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  conn.exec ("DELETE FROM memo
    WHERE id = #{params[:id]} ")
  redirect to('/memos')
end
