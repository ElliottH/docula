Gem::Specification.new do |s|
  s.name        =  'docula'
  s.version     =  '0.0.2'
  s.date        =  '2013-04-13'
  s.summary     =  ""
  s.description =  ""
  s.authors     =  ["Elliott Hillary"]
  s.email       =  'ejh67@cam.ac.uk'
  s.files       =  Dir["lib/docula/*.rb", "lib/docula/grammars/csimple*.rb"]
  s.executables << 'docula'
  s.homepage    =  'http://github.com/ElliottH/docula'

  s.add_dependency 'sqlite3', '~> 1.3'
  s.add_dependency 'treetop', '~> 1.4'
end
