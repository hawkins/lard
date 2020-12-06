require 'net/http'
require 'json'

# A set of utility functions for working with the Larder HTTP API
class Lard
  VERSION = '0.0.9'.freeze

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

  def download_all_bookmarks(filename)
    # Library is the root moz_place
    library = moz_place({
                          title: "",
                          id: "root________",
                          links: [],
                        })
    library[:index] = 0
    library[:id] = 1
    library[:root] = "placesRoot"

    folders.each do |folder|
      # TODO: Copy
      place = folder
      place[:links] = bookmarks folder[:id]
      library[:children].push(moz_place place)
    end

    # Export library to a file
    export_bookmarks_to_file library, filename
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
      request.add_field 'Content-Type', 'application/x-www-form-urlencoded'
    end
    request.add_field 'Authorization', "Token #{@token}"
    # TODO: How can we ensure this gets updated with every new version?
    request.add_field 'User-Agent', "Lard/#{VERSION}"
    request
  end

  def parse_response(res)
    JSON.parse res.body, symbolize_names: true
  end

  def export_bookmarks_to_file(library, filename)
    File.open(filename, "w") do |file|
      file << library.to_json
    end
  end

  def resolve_conflicts(alpha, beta)
    # Merge conflicts I want to be able to solve are:
    # - renamed name of link
    # - updated url of link
    # - updated tags on link
  end

  def time_string_to_ms(time)
    DateTime.strptime(time).to_time.to_i * 1000
  end

  # Creates a Mozilla Place from a Larder bookmark or folder
  #
  # Note that caller will need to supply an
  # integer `index` of the containing array
  # and an integer `id`
  def moz_place(item)
    # Determine if item is a bookmark or a folder
    is_bookmark = !item.has_key?(:links)

    moz_place = {}

    moz_place[:guid] = item[:id]
    moz_place[:title] = item[:title]
    moz_place[:dateAdded] = time_string_to_ms item[:created]
    moz_place[:lastModified] = time_string_to_ms item[:modified]

    # typeCode
    #   1 = bookmark
    #   2 = folder
    #   ? = separator
    if is_bookmark
      moz_place[:typeCode] = 1
    else
      moz_place[:typeCode] = 2
    end

    # type
    #   text/x-moz-place = bookmark
    #   text/x-moz-place-container
    #   ? = separator
    if is_bookmark
      moz_place[:type] = "text/x-moz-place"
    else
      moz_place[:type] = "text/x-moz-place-container"
    end

    # root
    #   placesRoot
    #   bookmarksMenuFolder
    #   toolbarFolder
    #   unfiledBookmarksFolder
    #   mobileFolder
    # TODO: how should we handle `root`?

    unless is_bookmark
      children = []

      item[:bookmarks].each_with_index do |bookmark, index|
        child = moz_place bookmark
        child[:index] = index
        # TODO: Add child[:id]
        children.push child
      end

      moz_place[:children] = children
    end

    # Some mappings don't have a home in mozilla's format
    # We'll save them in extra keys in hopes they still work
    moz_place[:tags] = bookmark[:tags]

    moz_place
  end
end
