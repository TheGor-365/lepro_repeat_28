require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
# require 'sqlite3'

# def init_db
#   @db = SQLite::Database.new 'leprosorium.sqlite'
#   @db.results_as_hash = true
# end

# method for posts.txt data

def posts_hash_maker columns, data
  data.collect { |row| { 
    columns[0] => row[0].strip, 
    columns[1] => row[1].strip, 
    columns[2] => row[2].strip 
  } }
end

# before do
#   init_db
# end

# before /index (main)

before do
  posts_txt = File.open 'public/data/posts.txt', 'r'

  @posts_columns = ['id', 'post_body', 'created_date']
  @posts_data = []

  posts_txt.each_line do |line|
    post = line.split(/\__/)
    @posts_data << post
  end

  @posts_data.reverse!

  @result_posts = posts_hash_maker @posts_columns, @posts_data

  posts_txt.close 
end

# before /details/:post_id

before do
  comments_txt = File.open 'public/data/comments.txt', 'a+'

  @comments_columns = ['post_id', 'comment', 'comment_date']
  @comments_data = []

  comments_txt.each_line do |line|
    comment = line.split(/\__/)
    @comments_data << comment
  end

  @result_comments = posts_hash_maker @comments_columns, @comments_data

  comments_txt.close
end

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

# sign in/sign out handlers

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

# git index/ (main)

get '/' do
  @result_posts

  # @results = @db.execute 'SELECT * FROM Posts 
  # ORDER BY id DESC'
  
  erb :index
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

# get /new
#---------

get '/new' do
  
  erb :new
end

# post /new
#----------

post '/new' do
  content = params[:content]

  if content.length <= 0
    @error = 'Input post text'
    return erb :new
  end

  d = DateTime.now
  d.strftime("%d.%m.%Y %H:%M")

  posts_txt = File.open 'public/data/posts.txt', 'a+' 
  posts_txt.write "#{$.}__#{content}__#{d.strftime("%d/%m/%Y %H:%M")}\n"
  posts_txt.close

  # @db.execute 'INSERT INTO Posts (content, created_date) 
  #   VALUES (?, datetime())', [content]

  redirect to '/' 
end

# get /details/:post_id
#----------------------

get '/details/:post_id' do
  post_id = params[:post_id]

  # results = @db.execute 'SELECT * FROM Posts 
  #   WHERE id = ?', [post_id]

  # @row = results[0]

  results = @result_posts.select {|post_hash| post_hash['id'] == post_id}
  @sm_array = results[0]

  # @comments = @db.execute 'SELECT * FROM Comments 
  #   WHERE post_id = ? 
  #   ORDER BY id', [post_id]

  @comments = @result_comments.select {|comment_hash| comment_hash['post_id'] == post_id}
  @comments.reverse!

  erb :details
end

# post /details/:post_id
#-----------------------

post '/details/:post_id' do
  post_id = params[:post_id]
  comment = params[:comment]
  
  
  if comment.length <= 0
    @error = 'Input comment text'
    return erb :details
  end

  d = DateTime.now
  d.strftime("%d.%m.%Y %H:%M")

  comments_txt = File.open 'public/data/comments.txt', 'a+'
  comments_txt.write "#{post_id}__#{comment}__#{d.strftime("%d/%m/%Y %H:%M")}\n"
  comments_txt.close

  # @db.execute 'INSERT INTO Comments (content, created_date, post_id) 
  #   VALUES (?, datetime(), ?)', [content, post_id]

  redirect to('/details/' + post_id)
end