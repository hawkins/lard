require 'lard'

RSpec.describe Lard, '#authorized' do
  it 'returns false to indicate user is unauthorized' do
    l = Lard.new
    expect(l.authorized).to be false
  end
  it 'returns true to indicate user has a token' do
    # Though we can't actually guarantee the token is authorized
    # without an http request
    l = Lard.new 'token'
    expect(l.authorized).to be true
  end
end

RSpec.describe Lard, '#api_url_prefix' do
  it "returns the Larder API's Base URL" do
    l = Lard.new
    url = l.api_url_prefix
    expect(url).to be_an_instance_of String
    expect(url).to be_an_start_with 'https://'
  end
end

RSpec.describe Lard, '#get' do
  it 'will fail if not authorized' do
    l = Lard.new
    expect(l.authorized).to be false
    expect { l.get 'user' }.to raise_error(RuntimeError)
  end
  it 'can make GET requests without params' do
    l = Lard.new 'token'
    expect(l.get('user')).to be_an_instance_of Hash
    expect(l.get('user')[:links]).to be_an_instance_of Integer
  end
  it 'can make GET requests with params' do
    l = Lard.new 'token'
    result = l.get('search', q: 'query')
    expect(result).to be_an_instance_of Hash
    expect(result[:results]).to be_an_instance_of Array
  end
end

RSpec.describe Lard, '#post' do
  it 'will fail if not authorized' do
    l = Lard.new
    expect(l.authorized).to be false
    expect { l.post 'bookmark', {} }.to raise_error(RuntimeError)
  end
  it 'can make POST requests' do
    l = Lard.new 'token'
    result =
      l.post 'links/add',
             'title' => 'a',
             'link' => 'https://b.com',
             'parent' => 'hash',
             'tags' => %w[d]
    expect(result).to be_an_instance_of Hash
    # TODO: Mock results
    # expect(result[...]).to equal "Ok"
  end
end

RSpec.describe Lard, '#folders' do
  it 'returns a list of folders' do
    l = Lard.new 'token'
    f = l.folders
    expect(f).to be_an_instance_of Array
    expect(f.size).to be > 0
    expect(f[0][:id]).to be_an_instance_of String
    expect(f[0][:name]).to be_an_instance_of String
    expect(f[0][:color]).to be_an_instance_of String
    expect(f[0][:links]).to be_an_instance_of Integer
    # We don't really handle nested folders yet, but maybe someday
    expect(f[0][:folders]).to be_an_instance_of Array
  end
end

RSpec.describe Lard, '#get_folder_by_name' do
  it 'returns a given folder' do
    l = Lard.new 'token'
    f = l.get_folder_by_name 'test'
    expect(f).to be_an_instance_of Hash
    expect(f[:id]).to be_an_instance_of String
    expect(f[:name]).to satisfy do |v| v == 'test' end
    expect(f[:links]).to be_an_instance_of Integer
  end
end

RSpec.describe Lard, '#tags' do
  it 'returns a list of tags' do
    l = Lard.new 'token'
    t = l.tags
    expect(t).to be_an_instance_of Array
    expect(t[0][:id]).to be_an_instance_of String
    expect(t[0][:name]).to be_an_instance_of String
    expect(t[0][:color]).to be_an_instance_of String
    expect(t[0][:color].size).to satisfy do |v| v == 6 end
  end
end

RSpec.describe Lard, '#bookmarks' do
  it 'returns a list of bookmarks' do
    l = Lard.new 'token'
    f = l.folders
    b = l.bookmarks f[0][:id]
    expect(b).to be_an_instance_of Array
    expect(b[0][:tags]).to be_an_instance_of Array
    expect(b[0][:title]).to be_an_instance_of String
    expect(b[0][:url]).to be_an_instance_of String
    expect(b[0][:url].start_with?(/https?:\/\//)).to be true
    expect(b[0][:description]).to be_an_instance_of String
  end
end

RSpec.describe Lard, '#offline' do
  it 'can upload bookmarks to Larder' do
    # Upload bookmarks from local store to Larder account
  end

  it 'can download bookmarks from Larder' do
    # Download bookmarks from Larder account to local store
  end

  it 'can resolve simple merge conflicts' do
    # Title changed but URL remained same
    # URL changed but Title remained same
    # Tags changed but either URL or Title remained same
  end

  it 'can sync bookmarks with Larder' do
    # Resolve merge conflicts with Larder and local store, updating both
  end

  it 'can merge bookmarks with another file' do
    # Resolve merge conflicts with local store and another local file, i.e. Firefox export
  end
end