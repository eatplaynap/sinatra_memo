# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

use Rack::MethodOverride

conn = PG.connect(dbname: 'sinatra_memo_db', user: 'eatplaynap')

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @title = '一覧'
  conn.prepare('show', 'SELECT * FROM memo ORDER BY $1')
  @memos = conn.exec_prepared('show', ['id'])
  conn.exec("DEALLOCATE show")
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.prepare('post', "INSERT INTO memo(memo_title, article)
  VALUES($1, $2)")
  conn.exec_prepared('post', [memo_title.to_s, article.to_s])
  conn.exec("DEALLOCATE post")
  redirect to('/memos')
end

get '/memos/:id' do
  @title = '詳細'
  conn.prepare('find', 'SELECT * FROM memo WHERE id = $1')
  @memo_info = conn.exec_prepared('find', [params[:id].to_s])
  conn.exec("DEALLOCATE find")
  erb :detail
end

get '/memos/:id/edit' do
  @title = '編集'
  conn.prepare('edit', 'SELECT * FROM memo WHERE id = $1')
  @memo_info = conn.exec_prepared('edit', [params[:id].to_s])
  conn.exec("DEALLOCATE edit")
  erb :edit
end

patch '/memos/:id' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.prepare('patch', 'UPDATE memo SET memo_title = $1, article = $2 WHERE id = $3')
  conn.exec_prepared('patch', [memo_title.to_s, article.to_s, params[:id].to_s])
  conn.exec("DEALLOCATE patch")
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  conn.prepare('delete', 'DELETE FROM memo WHERE id = $1')
  conn.exec_prepared('delete', [params[:id].to_s])
  conn.exec("DEALLOCATE delete")
  redirect to('/memos')
end
