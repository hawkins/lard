require 'httparty'

# A set of utility functions for working with the Larder HTTP API
class LardHTTP
  include HTTParty
  maintain_method_across_redirects

  def initialize(token = nil)
    @token = token
    @folders = []
  end

  def authorized
    !@token.nil?
  end

  def prefix
    'https://larder.io/api/1/@me/'
  end

  def get_folder_by_name(name)
    folders if @folders.empty?
    @folders.find do |folder|
      folder[:name] == name
    end
  end

  def tags
    res = get 'tags', limit: 200
    tags = res[:results] || []

    until res[:next].nil?
      res = raw_get res[:next]
      tags.push(*res[:results])
    end

    tags
  end

  def bookmarks(folder_id)
    res = get "folders/#{folder_id}", limit: 200
    bookmarks = res[:results] || []

    until res[:next].nil?
      res = raw_get res[:next]
      bookmarks.push(*res[:results])
    end

    bookmarks
  end

  def folders
    res = get 'folders', limit: 200
    @folders = res[:results] || @folders

    until res[:next].nil?
      res = raw_get res[:next]
      @folders.push(*res[:results])
    end

    @folders
  end

  # Perform a GET request to an endpoint in the Larder API
  def get(endpoint, params = nil)
    raise "You're not logged in! Run 'lard login' first." unless authorized

    opts = options.merge(query: params)
    res = self.class.get "#{prefix}#{endpoint}/", opts
    parse_response res
  end

  # Perform a POST request to an endpoint in the Larder API
  # Posts args as JSON in the post body, where args is a hash
  def post(endpoint, args = {})
    raise "You're not logged in! Run 'lard login' first." unless authorized

    opts = options.merge(body: args.to_json)
    res = self.class.post "#{prefix}#{endpoint}/", opts
    parse_response res
  end

  private

  # Options hash identifies the user for HTTP requests
  # Used with options.merge({body: ..., query: ...})
  def options
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Token #{@token}",
        'User-Agent' => 'Lard/0.0.6'
      }
    }
  end

  def parse_response(res)
    JSON.parse res.body, symbolize_names: true
  end

  # Makes a request to the explicit URL with only default options set
  def raw_get(url)
    raise "You're not logged in! Run 'lard login' first." unless authorized

    parse_response self.class.get(url, options)
  end
end
