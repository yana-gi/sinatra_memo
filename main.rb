# frozen_string_literal: true

require 'json'
require 'pg'
require 'sinatra'
require 'sinatra/reloader'

# メモデータを読み書きするクラス
class Memo
  attr_accessor :list

  def initialize(memo, connection)
    @list = memo
    @connection = connection
  end

  def self.load
    connection = PG::connect({ host: 'localhost', user: 'postgres', password: 'password', dbname: 'sinatra_memo' })

    results = connection.exec('SELECT * FROM memo ORDER BY id')
    memo = {}
    results.each do |result|
      memo[result['id']] = { 'title' => result['title'], 'text' => result['text'] }
    end

    Memo.new(memo, connection)
  end

  def create(memo_title, memo_text)
    sql = <<~SQL
      INSERT INTO memo(title, text, created_at, updated_at)
      VALUES($1, $2, current_timestamp, current_timestamp)
    SQL
    @connection.exec_params(sql, [memo_title, memo_text])
  end

  def edit(memo_title, memo_text, id)
    sql = <<~SQL
      UPDATE MEMO
      SET title = $1, text = $2, updated_at = current_timestamp
      WHERE id = $3
    SQL
    @connection.exec_params(sql, [memo_title, memo_text, id])
  end

  def delete(id)
    sql = <<~SQL
      DELETE FROM memo
      WHERE id = $1
    SQL
    @connection.exec_params(sql, [id])
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
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
  memo.create(memo_title, memo_text)
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
  memo.edit(memo_title, memo_text, @id)
  redirect to('/memos')
end

delete '/memos/:id' do
  @id = params[:id]
  memo = Memo.load
  memo.delete(@id)
  redirect to('/memos')
end
