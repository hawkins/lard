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
    get 'user'
  end

  private

  def get(endpoint)
    res = self.class.get "#{prefix}#{endpoint}", @options
    JSON.parse res.body, symbolize_names: true
  end

  def prefix
    '/api/1/@me/'
  end
end
