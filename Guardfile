guard :shell do
  watch /.*/ do |m|
    path = m[0]
    asset_type, args = if %r{^javascripts/.+$}.match path
      "javascripts"
    elsif %r{^stylesheets/.+$}.match path
      "stylesheets"
    elsif match = %r{^htmls/(.+)$}.match(path)
      ["html", [match[1]]]
    elsif %r{^spec/javascripts/.+$}.match path
      "specs"
    end
    if asset_type
      if args
        `rake "assets:compile_#{asset_type}[#{args.join(',')}]"`
      else
        `rake assets:compile_#{asset_type}`
      end
    end
  end
end
