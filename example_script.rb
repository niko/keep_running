puts "started at #{Time.now}"

puts "the script called is:"
p $0
puts

puts "arguments are:"
p ARGV
puts

sleep 10
puts "ended at #{Time.now}"
puts "Go to http://www.mailinator.com/maildir.jsp?email=keep_running_test to see the email."
