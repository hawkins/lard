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
  it 'returns the Larder API\'s Base URL' do
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
    result = l.post 'links/add',
                    'title' => 'a',
                    'link' => 'https://b.com',
                    'parent' => 'hash',
                    'tags' => ['d']
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
    expect(f[0][:links]).to be_an_instance_of Fixnum
    # We don't really handle nested folders yet, but maybe someday
    expect(f[0][:folders]).to be_an_instance_of Array
  end
end

# TODO: Test these functions
#   get_folder_by_name
#   tags
#   bookmarks
