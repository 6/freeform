guard :shell do
  watch /.*/ do |m|
    path = m[0]
    asset_type = if %r{^(javascripts|templates)/.+$}.match path
      "javascripts"
    elsif %r{^stylesheets/.+$}.match path
      "stylesheets"
    elsif %r{^htmls/.+$}.match path
      "htmls"
    elsif %r{^spec/javascripts/.+$}.match path
      "specs"
    end
    `rake assets:compile_#{asset_type}`  unless asset_type.nil?
  end
end
