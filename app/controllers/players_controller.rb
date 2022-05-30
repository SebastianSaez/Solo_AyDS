class PlayersController < Sinatra::Base
#
#  configure do
#    set :views, settings.root + '/../views'
#    set :sessions, true
#    set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
#  end
#
#  # This model will be responsable for anything involving our players as
#  # signup, login, logout, redirect to create forecast, redirect to watch 
#  # matches, etc.
#
#  # signup -> new session (get and post request)
#    # get for render the signup form
#    # post for process the signup form
#
#  # login -> read session ()
#  # logout -> delete actual session
#
#  get '/signup' do
#    erb :'players/signup'
#  end
#
#  post '/signup' do
#    # Recieve data from the form inside of params hash.
#    # Create a new player and persist it.
#    player = Player.new(params)
#
#    if player.save then
#      redirect to '/login'
#    else
#      redirect to '/signup'
#    end
#  end
#
#
#  get '/login' do
#    erb :'players/login'
#  end
#
#  post '/login' do
#  	player = Player.find_by(username: params[:username], email: params[:email])
#
#    if player && player.authenticate(params[:password])
#      session[:player_id] = player.id 
#      redirect to '/landingpage'
#    else
#      redirect '/login'
#    end
#  
#    #json = JSON.parse(params)
#    #player = Player.find_by(username: json['username'])
#    #if player && player.password == json['password']
#    #  session[:player_id] = player.id
#    #  redirect to "/landingpage"
#    #else
#    #  redirect to "/login"
#    #end
#  end
#
#  get '/logout' do
#    session.clear
#    redirect to '/login'
#  end
#
#  get '/landingpage' do
#    erb :'players/landingpage'
#  end
end