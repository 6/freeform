#!/usr/bin/env ruby

require 'colored'
require 'yaml'

ENV['RACK_ENV'] = 'production'
config = YAML.load_file('config/app.yml')

puts "* Compiling assets".green

`rake assets:compile_all`

puts "* Moving compiled assets to gh-pages".green

# TODO better way to do this?
`git branch -D gh-pages`
`git checkout -b gh-pages`
`rm .gitignore`
`echo "/.compiled" > .gitignore`
`git clean -f -d`
`git rm -r *`
`mv .compiled/* .`
`touch .nojekyll`
`echo "#{config['cname']}" > CNAME`  if config['cname']
`git add .`
`git commit -m 'Deploy #{Time.now.to_s}'`

puts "Ready to deploy. Run: ".green
puts "git push origin gh-pages".blue
