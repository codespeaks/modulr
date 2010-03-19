require 'rubygems'
require 'rake'
require 'lib/modulr'

COMMONJS_SPEC_DIR = File.join('vendor', 'commonjs', 'tests', 'modules', '1.0')

desc "Concatenate example file"
task :build_example do
  File.open(File.join('output', 'example.js'), 'w') do |f|
    f << Modulr.ize(File.join('example', 'program.js'))
  end
end

desc "Run CommonJS Module 1.0 specs"
task :spec do
  specs = ENV["SPECS"] || "**"
  
  FileList["#{COMMONJS_SPEC_DIR}/{#{specs}}/program.js"].each do |spec|
    dir = File.dirname(spec)
    output = File.join(dir, 'output.js')
    system = File.join(dir, 'system.js')
    FileUtils.touch(system)
    begin
      puts File.basename(dir).center(80, "_")
      File.open(output, 'w') do |f|
        f << Modulr.ize(spec)
      end
      system("js -f #{output}")
    rescue => e
      phase = e.is_a?(Modulr::ModulrError) ? "building" : "running"
      puts "ERROR while #{phase} (#{e.class}):"
      puts e.message
    ensure
      FileUtils.rm(output)
      FileUtils.rm(system)
      puts
      puts
    end
  end
end

begin
  require "jeweler"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "modulr"
    gemspec.summary = "A CommonJS module implementation in Ruby for client-side JavaScript"
    gemspec.author = "Tobie Langel"
    gemspec.email = "tobie.langel@gmail.com"
    gemspec.homepage = "http://github.com/codespeaks/modulr"
    gemspec.files = FileList["Rakefile", "README.markdown", "LICENSE", "VERSION", "{lib,bin,assets,example}/**/*", "vendor/rkelly/**/*"]
    gemspec.executable = "modulrize"
    gemspec.add_dependency("coffee_machine")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end
