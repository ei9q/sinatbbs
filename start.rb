require 'rubygems'
require 'sinatra'
require 'sequel'
Sequel::Model.plugin(:schema)

DB = Sequel.sqlite("comments.db")
class Comments < Sequel::Model
  set_schema do
    primary_key :id
    string :name
    string :title
    text :message
    timestamp :posted_date
  end

  def date
    self.posted_date.strftime("%Y-%m-%d %H:%M:%S")
  end

  def formatted_message
    Rack::Utils.escape_html(self.message).gsub(/\n/, "<br>")
  end
end
Comments.create_table unless Comments.table_exists?

helpers do
  include Rack::Utils; alias_method :h, :escape_html
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/' do
  @comments = Comments.order_by(Sequel.desc(:posted_date))
  haml :index
end

put '/comment' do
  Comments.create({
    :name => request[:name],
    :title => request[:title],
    :message => request[:message],
    :posted_date => Time.now,
  })

  redirect '/'
end
