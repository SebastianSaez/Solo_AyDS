require 'sinatra/base'
require 'bundler/setup'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require "sinatra/activerecord"
require_relative '../models/init.rb'

class App < Sinatra::Application
    
  configure :production, :development do
    enable :logging

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end
  

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded!!!'
      logger.info 'Reloaded!!!'
    end
  end


  def initialize(app = nil)
    super()
  end
    
  configure do
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  end


# Start Page  
  get '/' do
    erb:index
  end

  get '/login' do
    erb :'Login/Login'
  end

  get '/signup' do
    erb :CreateAccount
  end

  get '/Cuenta' do
    erb :Cuenta
  end

  #post '/login' do
  #  erb :'Usuario/usuario'
  #end

  get '/usuario' do
    erb :'Usuario/usuario'
  end
  get '/create' do
    erb :CreateAccount
  end

  post '/signup' do
  user = User.new(params)
    if user.save then
      session[:user_id] = user.id
      redirect to '/Cuenta'
    else
      redirect to '/login'
    end
  end


  post '/login' do
    user = User.find_by(username: params['username'])
    if user     # if there is an user with that username
      user = user.authenticate params['password']
      if user   # and the password is correct
        session[:user_id] = user.id
        redirect '/Cuenta'
      else
       redirect '/login'
      end
    else
      redirect 'login'
    end
  end

#  before do
#    if session[:user_id]
#      @current_user = User.find_by(id: session[:user_id])
#    else
#      public_pages = ["/", "/login", "/signup"]
#      if !public_pages.include?(request.path_info)
#        redirect '/login'
#      end
#    end
#  end

#  post '/login' do
#     json = JSON.parse(request.body.read)
#     user = User.find_by(name: json['name'])
#     if user && user.password == json['password']
#       session[:user_id] = user.id
#       redirect to "/play"
#    else
#       redirect to "/login"
#     end
#  end

  before do
    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    else
      public_pages = ["/", "/login", "/signup"]
      if !public_pages.include?(request.path_info)
        redirect '/login'
      end
    end
  end

end