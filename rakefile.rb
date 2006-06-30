require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
  rdoc.rdoc_dir = 'ym4r-doc/'
  rdoc.title    = "YM4R Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification::new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = 'ym4r'
  s.version = "0.4.1"
  s.summary = "Using Google Maps and Yahoo! Maps from Ruby and Rails"
  s.description = <<EOF
EOF
  s.author = 'Guilhem Vellut'
  s.email = 'guilhem.vellut+ym4r@gmail.com'
  s.homepage = "http://thepochisuperstarmegashow.com"
  
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = FileList["lib/**/*.rb", "lib/**/*.yml","lib/**/*.js","tools/**/*.rb","test/**/*.rb", "README","MIT-LICENSE","rakefile.rb"]
  s.test_files = FileList['test/test*.rb']

  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.rdoc_options.concat ['--main',  'README']
end

desc "Package the library as a gem"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
