require 'net/http'
require 'json'

# A set of utility functions for working with the Larder HTTP API
class Lard
  VERSION = '0.0.8'.freeze

  def initialize(token = nil)
    @token = token
    @folders = []
  end

  def authorized
    !@token.nil?
  end

  def api_url_prefix
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
      res = get res[:next]
      tags.push(*res[:results])
    end

    tags
  end

  def bookmarks(folder_id)
    res = get "folders/#{folder_id}", limit: 200
    bookmarks = res[:results] || []

    until res[:next].nil?
      res = get res[:next]
      bookmarks.push(*res[:results])
    end

    bookmarks
  end

  def folders
    res = get 'folders', limit: 200
    @folders = res[:results] || @folders

    until res[:next].nil?
      res = get res[:next]
      @folders.push(*res[:results])
    end

    @folders
  end

  # Perform a GET request to an endpoint in the Larder API
  def get(url, params = nil)
    raise "You're not logged in! Run 'lard login' first." unless authorized

    # Make a URI based on whether we received a full URL or just endpoint
    uri = prepare_uri url
    uri.query = URI.encode_www_form params unless params.nil?

    res = Net::HTTP.start uri.host, uri.port, use_ssl: true do |http|
      http.request prepare_request 'get', uri
    end
    parse_response res
  end

  # Perform a POST request to an endpoint in the Larder API
  # Posts args as JSON in the post body, where args is a hash
  def post(endpoint, args = {})
    raise "You're not logged in! Run 'lard login' first." unless authorized

    uri = prepare_uri endpoint
    request = prepare_request 'post', uri
    request.set_form_data args
    res = Net::HTTP.start uri.host, uri.port, use_ssl: true do |http|
      http.request request
    end
    parse_response res
  end

  private

  def prepare_uri(url)
    if url.start_with?('http://', 'https://')
      URI url
    else
      URI "#{api_url_prefix}#{url}/"
    end
  end

  def prepare_request(method, uri)
    case method
    when 'get'
      request = Net::HTTP::Get.new uri
    when 'post'
      request = Net::HTTP::Post.new uri
      request.add_field 'Content-Type', 'application/json'
    end
    request.add_field 'Authorization', "Token #{@token}"
    # TODO: How can we ensure this gets updated with every new version?
    request.add_field 'User-Agent', "Lard/#{VERSION}"
    request
  end

  def parse_response(res)
    JSON.parse res.body, symbolize_names: true
  end
end
