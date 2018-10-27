Gem::Specification.new do |s|
  s.name = 'lard'
  s.version = '0.0.6'
  s.summary = 'A third-party command line interface for larder.io'
  s.executables << 'lard'
  s.authors = ['hawkins']
  s.add_runtime_dependency 'httparty', '~> 0.16.2'
  s.add_runtime_dependency 'paint', '~> 2.0'
  s.add_runtime_dependency 'thor', '~> 0.20.0'
end
