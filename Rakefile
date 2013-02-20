require 'haml'
require 'haml_coffee_assets'
require 'sprockets'
require 'sprockets-sass'
require 'yui/compressor'
require 'uglifier'
require 'andand'
require 'colored'
require 'guard'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

ENV['RACK_ENV'] ||= 'development'
Config = YAML.load_file('config.yml')

class SprocketsEnvironmentBuilder
  def self.build(environment = :development)
    environment = environment.to_sym
    sprockets = Sprockets::Environment.new

    sprockets.append_path 'javascripts'
    sprockets.append_path 'stylesheets'
    sprockets.append_path 'spec/javascripts'

    if [:production, :test].include? environment
      sprockets.css_compressor = YUI::CssCompressor.new
      sprockets.js_compressor = Uglifier.new(mangle: false)
    end

    sprockets
  end
end

task :guard do
  Rake::Task["assets:compile_all"].invoke
  ::Guard.start
end

namespace :assets do
  desc 'compile/compress assets to static files for testing purposes'

  task :compile_all do
    FileUtils.rm_rf(Config['compile_folder'])
    %w{javascripts stylesheets specs html static}.each do |asset|
      Rake::Task["assets:compile_#{asset}"].invoke
    end
    puts "Finished asset precompilation".blue
  end

  task :compile_javascripts do
    compile_asset(Config['compile_folder'], 'application.js', ENV['RACK_ENV'])
  end

  task :compile_stylesheets do
    compile_asset(Config['compile_folder'], 'application.css', ENV['RACK_ENV'])
  end

  task :compile_specs do
    compile_asset(Config['spec_compile_folder'], 'spec.js', :test)
  end

  task :compile_html, :path do |t, args|
    if path = args.andand[:path]
      folder, filename = path.split("/")
      if filename == Config['layout_filename']
        compile_all_htmls(folder)
      else
        compile_html(folder, filename)
      end
    else
      compile_all_htmls
    end
  end

  # Not actually compiling, just copying file to directory
  task :compile_static, :filename do |t, args|
    if filename = args.andand[:filename]
      copy_static(filename)
    else
      # Copy all static files
      Dir['static/**/*'].each do |path|
        next  unless File.file?(path)
        relative = path.split("/")[1..-1].join("/")
        copy_static(relative)
      end
    end
  end
end

def compile_asset(parent_dir, filename, environment)
  sprockets = SprocketsEnvironmentBuilder.build(environment)
  FileUtils.mkdir_p(parent_dir)
  sprockets.find_asset(filename).write_to(File.join(parent_dir, "assets", filename))
  puts "Compiled: #{filename.green}"
end

def compile_all_htmls(folder = "**")
  Dir["htmls/#{folder}/*.haml"].each do |path|
    next  if path.end_with?(Config['layout_filename'])
    _, folder, filename = path.split("/")
    compile_html(folder, filename)
  end
end

def compile_html(folder, filename)
  contents = File.read("./htmls/#{folder}/#{filename}")
  html = begin
    if Dir["htmls/#{folder}/#{Config['layout_filename']}"].empty?
      haml(contents)
    else
      layout_contents = File.read("./htmls/#{folder}/#{Config['layout_filename']}")
      haml layout_contents, Object.new, {} do
        haml(contents)
      end
    end
  rescue => e
    "<h1 style='color:red'>#{e.message}</h1>"
  end
  # _root folder is a special case where files will be placed in root
  new_path = "./#{Config['compile_folder']}/#{folder == Config['root_folder'] ? "" : "#{folder}/"}"
  unless File.directory?(new_path)
    FileUtils.mkdir_p(new_path)
  end
  new_filename = "#{filename.split(".")[0..-2].join(".")}.html"
  File.open("#{new_path}#{new_filename}", "w") do |file|
    file.write(html)
  end
  puts "Compiled: #{folder}/#{filename.magenta}"
end

def haml(contents, scope = Object.new, locals = {}, &block)
  Haml::Engine.new(contents).render(scope, locals, &block)
end

def copy_static(filename)
  if filename.split("/").size > 1
    folders = filename.split("/")[0..-2].join("/")
    FileUtils.mkdir_p("#{Config['compile_folder']}/#{folders}")
  end
  FileUtils.copy("./static/#{filename}", "#{Config['compile_folder']}/#{filename}")
  puts "Copied: #{filename.yellow}"
end
