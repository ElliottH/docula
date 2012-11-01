require 'rake/testtask'

desc 'Generate the parsers from Treetop files.'
task :grammars do
  system('tt lib/grammars/*.treetop')
end

Rake::TestTask.new(:tests) do |t|
  t.libs << "libs"
  t.test_files = FileList['tests/test_c.rb']
  t.warning = true
  t.verbose = false
end
task(:tests).comment.replace "Run the tests!" unless task(:tests).comment.nil?
