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

  def folders(limit = nil, offset = nil)
    params = { limit: limit, offset: offset }
    get 'folders', params
  end

  private

  def get(endpoint, params = nil)
    query = { query: params }
    opts = @options.merge query
    res = self.class.get "#{prefix}#{endpoint}", opts
    JSON.parse res.body, symbolize_names: true
  end

  def prefix
    '/api/1/@me/'
  end
end
