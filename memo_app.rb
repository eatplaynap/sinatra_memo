# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"
require "securerandom"

use Rack::MethodOverride

helpers do
  def convert_json_into_hash(params)
    @elements = File.open(params) do |file|
      JSON.parse(file.read)
    end
  end
end

get "/memos" do
  file_names = Dir.glob("*.json")
  @names = file_names.map do |file_name|
    convert_json_into_hash(file_name)
  end
  erb :index
end

get "/memos/new" do
  erb :new
end

post "/memos/new" do
  @memo_title = params[:memo_title]
  @article = params[:article]
  hash = { "id" => SecureRandom.uuid, "memo_title" => @memo_title, "article" => @article }
  File.open("memo.#{hash["id"]}.json", "w") do |file|
    file.puts JSON.pretty_generate(hash)
  end
  redirect to("/memos")
end

get "/memos/:id" do
  convert_json_into_hash(params[:id].to_s)
  erb :detail
end

get "/memos/:id/edit" do
  convert_json_into_hash(params[:id].to_s)
  erb :edit
end

patch "/memos/:id" do
  hash = convert_json_into_hash(params[:id].to_s)
  hash["memo_title"] = params[:memo_title]
  hash["article"] = params[:article]
  File.open(params[:id].to_s, "w") do |file|
    JSON.dump(hash, file)
  end
  redirect to("/memos/#{params[:id]}")
end

delete "/memos/:id" do
  File.delete(params[:id].to_s)
  redirect to("/memos")
end
