require 'sinatra/base'
require 'jwt'
require 'json'
require_relative 'jwt_auth'

class Api < Sinatra::Base

  use JwtAuth

  def initialize
    super

    @accounts = {
        claudiu: 12,
        raluca: 120,
    }
  end

  get '/money' do
    content_type :json
    scopes, user = request.env.values_at :scopes, :user
    username = user['username'].to_sym
    if scopes.include?('view_money') && @accounts.has_key?(username)
      content_type :json
      { money: @accounts[username] }.to_json
    else
      halt 403
    end
  end

end

class Public < Sinatra::Base

  def initialize
    super

    @logins = {
        claudiu: 'claudiu',
        raluca: 'raluca',
    }

  end

  post '/login' do

    username = params[:username]
    password = params[:password]


    if @logins[username.to_sym] == password
      content_type :json

      {token: token(username)}.to_json
    else
      halt 401
    end
  end

  def token(username)
    payload = payload(username)
    JWT.encode(payload, 'API', 'HS256')
  end

  def payload(username)
   {
       exp: Time.now.to_i + 60 * 60,
       iat: Time.now.to_i,
       iss: 'api.c',
       scopes: %w(add_money remove_money view_money),
       user: {
           username: username
       }
   }
  end
end
