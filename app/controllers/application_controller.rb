require './config/environment'
require 'pry'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    if Helpers.is_logged_in?(session)
      erb :index
    else
      redirect '/login'
    end
  end

  get '/login' do
    if Helpers.is_logged_in?(session)
      redirect '/posts'
    else
      erb :login
    end
  end

  post '/login' do
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect '/posts'
      else
        redirect '/login'
      end
  end

  get '/signup' do
    if Helpers.is_logged_in?(session)
      redirect '/posts'
    else
      erb :signup
    end
  end

  post '/signup' do
    user = User.create(params)
    if user.valid?
      session[:id] = user.id
      redirect '/posts'
    else
      redirect '/signup'
    end
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

  get '/posts' do
    if Helpers.is_logged_in?(session)
      @user = User.find(session[:id])
      @posts = @user.posts
      erb :'posts/index'
    else
      redirect '/login'
    end
  end




end


class Helpers
  def self.current_user(session)
    user = User.find(session[:id])
    rescue ActiveRecord::RecordNotFound
  end

  def self.is_logged_in?(session)
    session[:id] != nil && !!self.current_user(session)
  end
end
