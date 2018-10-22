require 'httparty'
require 'paint'

class Lard
  include HTTParty
  base_uri 'https://larder.io'

  def initialize(token)
    @options = {
      headers: {
        'Authorization' => "Token #{token}"
      }
    }
    @folders = []
  end

  def user
    # Print information about the user

    puts get('user')
  end

  def folders
    # Print all folders

    if @folders == []
      fetch_folders
    end

    @folders.each do |folder|
      print_folder_name folder
    end
  end

  def folder(name)
    # Print bookmarks from a given folder

    folder = get_folder_by_name name
    print_folder_name folder

    bookmarks = fetch_bookmarks folder[:id]
    bookmarks.each do |bookmark|
      print_bookmark bookmark
    end
  end

  private

  def print_bookmark(bookmark)
    puts "#{bookmark[:title]}"
    puts " #{bookmark[:description]}"
    puts " #{bookmark[:url]}"
      
    if !bookmarks[:tags].empty?
      bookmarks[:tags].each do |tag|
        print Paint[tag[:name], tag[:color]]
        print " "
      end
      puts " "
    end
  end

  def print_folder_name(folder)
    print Paint[folder[:name], folder[:color]]
    puts ":\t#{folder[links]} links"
  end

  def fetch_bookmarks(folder_id)
    # TODO: Verify pagination logic
    res = get "folders/#{folder_id}"
    bookmarks = res[:results] || []

    while res[:next] != nil
      params = { offset: res[:next] }
      res = get "folders/#{folder_id}", params
      bookmarks.push *res[:results]
    end

    bookmarks
  end

  def fetch_folders
    # TODO: Verify pagination logic
    res = get 'folders'
    @folders = res[:results]

    while res[:next] != nil
      params = { offset: res[:next] }
      res = get 'folders', params
      @folders.push *res[:results]
    end

    # TODO: Cache these folders
  end

  def get_folder_by_name(name)
    @folders.find do |folder|
      folder[:name] == name
    end
  end

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
