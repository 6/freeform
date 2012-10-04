require 'haml'
require 'haml_coffee_assets'
require 'sprockets'
require 'sprockets-sass'
require 'yui/compressor'
require 'uglifier'

class SprocketsEnvironmentBuilder
  def self.build(environment = :development)
    environment = environment.to_sym
    sprockets = Sprockets::Environment.new

    sprockets.append_path 'javascripts'
    sprockets.append_path 'stylesheets'
    sprockets.append_path 'templates'
    sprockets.append_path 'spec/javascripts'

    if [:production, :test].include? environment
      sprockets.css_compressor = YUI::CssCompressor.new
      sprockets.js_compressor = Uglifier.new(mangle: false)
    end

    sprockets
  end
end

require 'colored'
require 'guard'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

task :guard do
  Rake::Task["assets:compile_all"].invoke
  ::Guard.start
end

task :test do
  Rake::Task["assets:compile_all"].invoke
  Rake::Task["jasmine"].invoke
end

namespace :assets do
  desc 'compile/compress assets to static files for testing purposes'

  task :compile_all do
    %w{javascripts stylesheets specs htmls}.each do |asset|
      Rake::Task["assets:compile_#{asset}"].invoke
    end
    puts "Finished asset precompilation".blue
  end

  task :compile_javascripts do
    compile_asset('.compiled', 'application.js', :development)
  end

  task :compile_stylesheets do
    compile_asset('.compiled', 'application.css', :development)
  end

  task :compile_specs do
    compile_asset('spec/.compiled', 'spec.js', :test)
  end

  task :compile_htmls do
    compile_html('index.haml')
  end
end

def compile_asset(parent_dir, filename, environment)
  sprockets = SprocketsEnvironmentBuilder.build(environment)
  FileUtils.mkdir_p(parent_dir)
  sprockets.find_asset(filename).write_to(File.join(parent_dir, filename))
  puts "Compiled: #{filename.green}"
end

def compile_html(filename, scope = Object.new, locals = {})
  contents = File.read("./htmls/#{filename}")
  html = begin
    Haml::Engine.new(contents).render(scope, locals)
  rescue => e
    "<h1>#{e.message}</h1>"
  end
  new_filename = "#{filename.split(".")[0..-2].join(".")}.html"
  File.open("./#{new_filename}", "w") do |file|
    file.write(html)
  end
  puts "Compiled: #{filename.magenta}"
end
