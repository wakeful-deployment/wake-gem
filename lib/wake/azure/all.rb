Dir["#{File.expand_path("..", __FILE__)}/**/*.rb"].each do |file|
  require file
end
