require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'


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

get '/' do
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

  erb "#{content}"
end