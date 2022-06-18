require 'sinatra/base'
require 'bundler/setup'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'logger'
require "sinatra/activerecord"
require_relative '../models/init.rb'
require 'sinatra/flash'

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
  get '/login/result' do
      @tournament = Matchtournament.where(tournament:params[:id_tournament])
      @team = Match.all
      if (@tournament != nil && session[:user_id]  == 1 )then 
         erb:'Admin/result'
      else
        if (@tournament != nil && session[:user_id]  != 1 )then 
          erb:'Usuario/result'
        else
          erb:'Admin/home'
        end
      end
  end

   get '/login/adminresult' do
    @tournament = Matchtournament.find_by(tournament:params[:id_tournament])
    @team = Match.find_by(id:params[:id_match])
    forecast = Forecast.all
    if (forecast == [] ) then 
      flash[:error] = "No hay ningun pronostico"
      redirect "/login/home"
    else
      erb:'Play/game'
    end
    #  if (@tournament == nil)then 
    #     erb:'Admin/home'
    #  else
    #    erb:'Play/game'
    #  end
   end

    post '/login/adminresult' do
      forecast = Forecast.where(match:params[:id_match])
      if (forecast != [] )then
        forecast.each do |fore|
          if (fore.win == nil)then
            if (params[:local_goal] < params[:visitor_goal]) then 
              fore.win = fore.match.visitor.id
            else
              if (params[:local_goal] > params[:visitor_goal]) then 
                fore.win = fore.match.local.id
              else
                fore.win = 0
              end
            end
            fore.local_goal = params[:local_goal]
            fore.visitor_goal = params[:visitor_goal]
            fore.save
          else
            flash[:error] = "Ya tiene un resultado."
            redirect "/login/home"
          end
        end
        usuarios = Forecast.all
        prueba = Forecast.find_by(match:params[:id_match])
        usuarios.each do |algo|
          if ((algo.match.id == prueba.match.id) && (algo.result == prueba.win))then 
            algo.user.point = algo.user.point + 3
            if (algo.user.streak == 2)then 
              algo.user.streak = 0
              algo.user.point = algo.user.point + 3
            else
              algo.user.streak = algo.user.streak + 1
            end
            algo.user.save
          else
            if (algo.match.id == prueba.match.id && algo.result != prueba.win)then 
              algo.user.point = algo.user.point + 1
            end
            algo.user.streak = 0
            algo.user.save
          end
        end
        flash[:success] = "Se cargo resultado del partido"
        redirect "/login/home"
      else
        flash[:error] = "No hay ningun pronostico.."
        redirect "/login/home"
      end
    end

  get '/login/game' do
      @tournament = Matchtournament.where(tournament:params[:id_tournament])
      @team = Match.find_by(id:params[:id_match])
      if (@tournament == nil)then 
         erb:'Usuario/home'
      else
        erb:'Usuario/game'
      end
  end

  post '/login/game' do
    forecast = Forecast.new
    forecast.user = User.find_by_id(session[:user_id])
    forecast.match = Match.find_by(id:params[:id_match])
    if (params[:local_goal]< params[:visitor_goal]) then 
      forecast.result = forecast.match.visitor.id 
    else
      if (params[:local_goal] > params[:visitor_goal]) then 
        forecast.result = forecast.match.local.id 
      else
        forecast.result = 0
      end
    end

    hola = Forecast.find_by(user:forecast.user,match:forecast.match)
    if (hola == nil )then
      forecast.save
      flash[:success] = "Se cargo pronostico"
      redirect "/login/home"
    else
      flash[:error] = "Ya tienes un pronostico"
      redirect "/login/home"
    end
  end


  get '/login/createtournament' do
      erb:'Admin/createtournament'
  end

  get '/login/matchtour' do
      @tournament = Tournament.all
      @team = Match.all
      if (Tournament.first != nil) then
        erb:'Admin/matchtournament'
      else
        redirect "/login/home"
      end
  end

  post '/login/matchtour' do
      primero = Tournament.find_by(name:params[:tournament])
      ala = Matchtournament.find_by(match:params[:team],tournament:primero)
      if (ala == nil) then 
        crear = Matchtournament.new
        flash[:success] = "Se agrego partido al torneo"
        crear.tournament = primero
        crear.date = params[:date]
        crear.hour = params[:time]
        primero = Match.find_by(id:params[:team])
        crear.match = primero
        crear.save
        redirect "/login/matchtour"
      else
        flash[:error] = "No puedes agregar el mismo partido al torneo"
        redirect "/login/matchtour"
      end
  end

  post '/login/createtournament' do
    torneo = Tournament.new
    a = Tournament.find_by(name:params[:name].upcase!)
    if (a == nil)then 
      flash[:success] = "Se creo el torneo exitosamente!."
      torneo.name = params[:name]
      torneo.save
      redirect "/login/createtournament"
    else
      flash[:error] = "El nombre del torneo ya esta en uso"
      redirect "/login/createtournament"
    end
  end


  get '/login/home' do
    @todo = Matchtournament.all.order('tournament_id ASC')
    @forecast = Forecast.all
    @match = Match.all
    if session[:user_id]  == 1 then
      erb:'home/homeAdmin'
    else
      erb:'Usuario/homeUser'
    end
  end

  get '/login/history' do
    @fore = Forecast.where(user:session[:user_id])
    forecast = Forecast.find_by(user:session[:user_id])
    erb:'Usuario/history'
  end



  get '/login/ranking' do
    @user = User.order('point DESC')
    if session[:user_id] == 1 then
       erb:'Admin/ranking'
    else
      erb:'Usuario/ranking'
    end
  end


  get '/login/match' do
    @teams = Team.all
    erb:'Match/newM'
  end

  get '/login/team' do
    erb:'Team/newTeam'
  end


  post '/login/team' do
    team = Team.new
    team.name = params[:name].upcase!
    if (Team.exists?(name:params[:name])) then
        flash[:error] = "Ya hay equipo con ese nombre."
        redirect '/login/team'
    else
      team.save
      flash[:success] = "Equipo creado!."
      redirect '/login/team'
    end
  end

  get '/login/logout' do
    session.clear
    redirect '/'
  end


  post '/login/match' do
    match1 = Match.new
    auxlocal = Team.find_by_name(params[:local])
    match1.local = auxlocal
    auxvisitor = Team.find_by_name(params[:visitor])
    match1.visitor = auxvisitor
    if (match1.local == match1.visitor ) then
      flash[:error] = "Local y visitante son los mismos"
      redirect '/login/match'
    else
      flash[:success] = "Partido generado con exito"
      match1.save
      redirect "/login/match"
    end
  end

  get '/' do
    erb:index
  end

  get '/login' do
    erb :'Login/Login'
  end

  get '/signup' do
    erb :CreateAccount
  end

  get '/usuario' do
    if session[:user_id] == 1 then
      erb :'Admin/Admin'
    else
      erb :'Usuario/usuario'
    end
  end

  get '/create' do
    erb :CreateAccount
  end

  post '/signup' do
    user = User.new(params)
    if (User.exists?(username:params[:username])) then
      flash[:error] = "Username ya existente.."
      redirect to '/signup'
    end
    if (User.exists?(email:params[:email])) then
      flash[:error] = "Email ya existente.."
      redirect to '/signup'
    end
    if !(user.save) then
      flash[:error] = "No se pudo crear la cuenta"
      redirect to '/signup'
    else
      session[:user_id] = user.id
      redirect to '/usuario'
    end
    #  if user.save then
    #    session[:user_id] = user.id
    #    redirect to '/usuario'
    #  else
    #    redirect to '/signup'
    #  end
  end


  post '/login' do
    user = User.find_by(username: params['username'])
    if (user != nil) then
      if (user && user.authenticate(params[:password])) then
       session[:user_id] = user.id
       redirect '/usuario'
      else
        flash[:error] = "password incorrecto."
        redirect '/login'
      end
    else
      flash[:error] = "Username incorrecto."
      redirect '/login'
    end

#     user = User.find_by(username: params['username'])
#     if user     # if there is an user with that username
#       user = user.authenticate params['password']
 #      if user   # and the password is correct
#         session[:user_id] = user.id
#         redirect '/usuario'
#       else
#        redirect '/login'
#       end
#     else
#       redirect 'login'
#     end
  end

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