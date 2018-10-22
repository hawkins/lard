require 'httparty'

class Lard
  include HTTParty
  base_uri 'https://larder.io'

  def initialize(token)
    @options = {
      headers: {
        'Authorization' => "Token #{token}"
      }
    }
  end

  def user
    res = self.class.get '/api/1/@me/user', @options
    JSON.parse res.body, symbolize_names: true
  end

end
