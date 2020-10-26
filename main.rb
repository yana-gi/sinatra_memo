# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

# メモデータを読み書きするクラス
class Memo
  attr_accessor :list

  def initialize(json_data, json_file_path)
    @json_file_path = json_file_path
    @json_data = json_data
    @list = @json_data['memo']
  end

  def self.load
    json_file_path = './data/memo.json'
    json = File.open(json_file_path).read
    json_data = JSON.parse(json)
    Memo.new(json_data, json_file_path)
  end

  def save(memo_title, memo_text, id = nil)
    id ||= @json_data['last_id'] += 1
    @list[id] = { title: memo_title, text: memo_text }
    File.open(@json_file_path, 'w') { |io| JSON.dump(@json_data, io) }
  end

  def delete(id)
    @list.delete(id)
    File.open(@json_file_path, 'w') { |io| JSON.dump(@json_data, io) }
  end
end

get '/memos' do
  @title = 'Top'
  memo = Memo.load
  @memo_list = memo.list
  erb :top
end

post '/memos' do
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = Memo.load
  memo.save(memo_title, memo_text)
  redirect to('/memos')
end

get '/memos/new' do
  @title = 'New memo'
  erb :new
end

get '/memos/:id/edit' do
  @title = 'Edit memo'
  @id = params[:id]
  memo = Memo.load
  @memo_list = memo.list
  erb :edit
end

get '/memos/:id' do
  @title = 'Show memo'
  @id = params[:id]
  memo = Memo.load
  @memo_list = memo.list
  erb :show
end

patch '/memos/:id' do
  @id = params[:id]
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = Memo.load
  memo.save(memo_title, memo_text, @id)
  redirect to('/memos')
end

delete '/memos/:id' do
  @id = params[:id]
  memo = Memo.load
  memo.delete(@id)
  redirect to('/memos')
end
