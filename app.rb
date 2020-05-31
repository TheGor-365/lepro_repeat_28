require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
# require 'sqlite3'

# def init_db
#   @db = SQLite::Database.new 'leprosorium.sqlite'
#   @db.results_as_hash = true
# end

# before do
#   init_db
# end

# configure do
#   init_db
#   db.execute 'CREATE TABLE IF NOT EXISTS Posts (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     created_date DATE,
#     content TEXT
#   )'
# end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Logged out'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Enter your username and password' 
    halt erb(:login_form)
  end
end

get '/login/form' do
  erb :login_form
end

get '/logout' do
  session.delete(:identity)

  redirect to '/'
end

get '/secure/place' do
  erb :cab
end

before do
  @f = File.open 'public/posts/posts.txt', 'r+'
  @arr = []
  @hh = {}

  @f.each_line do |line|
    value = line.split(/\__/)
    @arr << value
  end

  @posts_as_array = @arr

  @arr.each do |item|
    @hh[item[0]] = item[1]
  end

  @posts_as_hash = @hh
end

get '/' do
  # @results = @db.execute 'SELECT * FROM Posts ORDER BY id DESC'
  
  erb :index
end

get '/new' do
  erb :new
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

post '/new' do
  content = params[:content]

  if content.length <= 0
    @error = 'Input post text'
    return erb :new
  end

  d = DateTime.now
  d.strftime("%d.%m.%Y %H:%M")

  @f = File.open 'public/posts/posts.txt', 'a+' 
  @f.write "#{$.}__#{content}__#{d.strftime("%d/%m/%Y %H:%M")}\n"
  @f.close

  # @db.execute 'INSERT INTO Posts (content, created_date) VALUES (?, datetime())', [content]

  redirect to '/' 
end

get '/details/:post_id' do
  post_id = params[:post_id]

  # @results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  @row = @posts_as_array[0]

  erb :details
end