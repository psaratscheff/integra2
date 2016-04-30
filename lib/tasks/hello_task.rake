desc "Say Hello world"
task :say_hi do
  puts "Hello world!"
  result = HTTParty.get("http://localhost:3000/api/documentacion")
end
