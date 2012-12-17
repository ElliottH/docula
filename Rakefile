require 'rake/testtask'

desc 'Generate the parsers from Treetop files.'
task :grammars do
  system('tt lib/grammars/*.treetop')
end

Rake::TestTask.new(:test) do |t|
  t.libs << "libs"
  #t.test_files = FileList['tests/test_c.rb']
  t.test_files = FileList['tests/test_csimple.rb']
  t.warning = true
  t.verbose = false
end
task(:test).comment.replace "Run the tests!" unless task(:test).comment.nil?
