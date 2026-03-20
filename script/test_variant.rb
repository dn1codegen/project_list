f = ProjectFile.first

puts "Testing variant creation..."
puts "File: #{f.file.filename}"

begin
  v = f.file.variant(resize_to_limit: [ 300, 300 ])
  puts "Variant created: #{v.class}"

  url = Rails.application.routes.url_helpers.rails_representation_url(v, only_path: true)
  puts "URL: #{url}"

  puts "Success!"
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(10).join("\n")
end
