require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'date'

class Memo
  @json_file_path = './public/memo.json'
  @numbering_id = 1

  def self.load
    json = File.open(@json_file_path).read
    JSON.parse(json)
  end

  def self.id
    nowtime = DateTime.now
    nowtime.strftime('%Y%m%d_%H%M%S')
  end

  def self.make(memo_title, memo_text)
    json_data = self.load
    @numbering_id += 1
    json_data[@numbering_id] = { title: memo_title, text: memo_text }
    File.open(@json_file_path, 'w') { |io| JSON.dump(json_data, io) }
  end

  def self.edit(memo_title, memo_text, id)
    json_data = self.load
    json_data[id] = { title: memo_title, text: memo_text }
    File.open(@json_file_path, 'w') { |io| JSON.dump(json_data, io) }
  end

  def self.delete(id)
    json_data = self.load
    json_data.delete(id)
    File.open(@json_file_path, 'w') { |io| JSON.dump(json_data, io) }
  end
end

get '/memos' do
  @title = 'Top'
  @memos = Memo.load
  erb :top
end

get '/memos/new' do
  @title = 'New memo'
  erb :new
end

post '/memos' do
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  Memo.make(memo_title, memo_text)
  redirect to('/memos')
end

get '/memos/:id/edit' do
  @title = 'Edit memo'
  @id = params[:id]
  @memo = Memo.load
  erb :edit
end

patch '/memos/:id' do
  @id = params[:id]
  memo_title = params[:memo_title]
  memo_text = params[:memo_text]
  Memo.edit(memo_title, memo_text, @id)
  redirect to('/memos')
end

get '/memos/:id' do
  @title = 'Show memo'
  @id = params[:id]
  @memo = Memo.load
  erb :show
end

delete '/memos/:id' do
  @id = params[:id]
  Memo.delete(@id)
  redirect to('/memos')
end
