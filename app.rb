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

#   db.execute 'CREATE TABLE IF NOT EXISTS Comments (
#     id INTEGER PRIMARY KEY AUTOINCREMENT,
#     created_date DATE,
#     content TEXT,
#     post_id INTEGER
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
  @arr2 = []
  @hh = {}

  @f.each_line do |line|
    value = line.split(/\__/)
    @arr << value
  end

  @posts_as_array = @arr

  @arr.each_with_index do |sm_arr, i|
    @hh[:id] = [sm_arr[0]]
    @hh[:post_body] = sm_arr[1]
    @hh[:created_date] = sm_arr[2]

    @arr2 << @hh
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
  # @row = results[0]

  @row = @posts_as_array[0]

  # @comments = @db.execute 'SELECT * FROM Comments WHERE post_id = ? ORDER BY id', [post_id]

  erb :details
end

before '/details/:post_id' do
  @f2 = File.open 'public/posts/comments.txt', 'a+'

  @arr_c = []
  @arr2_c = []
  @hh_c = {}

  @f2.each_line do |line|
    value = line.split(/\__/)
    @arr_c << value
  end

  @c_as_array = @arr

  @arr.each_with_index do |sm_arr, i|
    @hh_c[:id] = [sm_arr[0]]
    @hh_c[:post_body] = sm_arr[1]
    @hh_c[:created_date] = sm_arr[2]

    @arr2_c << @hh_c
  end

  @c_as_hash = @hh_c
end

post '/details/:post_id' do
  comment = params[:comment]
  post_id = params[:post_id]

  content = params[:content]

  if comment.length <= 0
    @error = 'Input comment text'
    return erb :details
  end

  d = DateTime.now
  d.strftime("%d.%m.%Y %H:%M")

  @f2 = File.open 'public/posts/comments.txt', 'a+'
  @f2.write "#{post_id}__#{comment}__#{d.strftime("%d/%m/%Y %H:%M")}\n"
  @f2.close

  # @db.execute 'INSERT INTO Comments (content, created_date, post_id) VALUES (?, datetime(), ?)', [content, post_id]

  redirect to('/details/' + post_id)
end