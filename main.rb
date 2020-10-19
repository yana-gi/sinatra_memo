# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'date'

class Memo
  def initialize
    @json_file_path = './public/memo.json'
    json = File.open(@json_file_path).read
    @json_data = JSON.parse(json)
  end

  def load
    @json_data['memo']
  end

  def save(memo_title, memo_text, id = nil)
    memos = load
    memos[id ||= make_id] = { title: memo_title, text: memo_text }
    File.open(@json_file_path, 'w') { |io| JSON.dump(@json_data, io) }
  end

  def make_id
    @json_data['last_id'] += 1
  end

  def delete(id)
    memos = load
    memos.delete(id)
    File.open(@json_file_path, 'w') { |io| JSON.dump(@json_data, io) }
  end
end

get '/memos' do
  @title = 'Top'
  memo = Memo.new
  @memos = memo.load
  erb :top
end

post '/memos' do
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = Memo.new
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
  memo = Memo.new
  @memo = memo.load
  erb :edit
end

get '/memos/:id' do
  @title = 'Show memo'
  @id = params[:id]
  memo = Memo.new
  @memo = memo.load
  erb :show
end

patch '/memos/:id' do
  @id = params[:id]
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  memo = Memo.new
  memo.save(memo_title, memo_text, @id)
  redirect to('/memos')
end

delete '/memos/:id' do
  @id = params[:id]
  memo = Memo.new
  memo.delete(@id)
  redirect to('/memos')
end
