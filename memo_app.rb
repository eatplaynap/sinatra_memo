# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'

use Rack::MethodOverride

conn = PG.connect(dbname: 'sinatra_memo', user: 'postgres')
conn.prepare('find_all', 'SELECT * FROM memo ORDER BY $1')
conn.prepare('find', 'SELECT * FROM memo WHERE id = $1')
conn.prepare('post', 'INSERT INTO memo(memo_title, article) VALUES($1, $2)')
conn.prepare('patch', 'UPDATE memo SET memo_title = $1, article = $2 WHERE id = $3')
conn.prepare('delete', 'DELETE FROM memo WHERE id = $1')

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/memos' do
  @title = '一覧'
  @memos = conn.exec_prepared('find_all', ['id'])
  erb :index
end

get '/memos/new' do
  @title = '新規作成'
  erb :new
end

post '/memos' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.exec_prepared('post', [memo_title, article])
  redirect to('/memos')
end

get '/memos/:id' do
  @title = '詳細'
  @memo_info = conn.exec_prepared('find', [params[:id]])
  erb :detail
end

get '/memos/:id/edit' do
  @title = '編集'
  @memo_info = conn.exec_prepared('find', [params[:id]])
  erb :edit
end

patch '/memos/:id' do
  memo_title = params[:memo_title]
  article = params[:article]
  conn.exec_prepared('patch', [memo_title.to_s, article.to_s, params[:id].to_s])
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  conn.exec_prepared('delete', [params[:id].to_s])
  redirect to('/memos')
end
