@columns = ['id', 'body', 'date']

@data = [

	["1", "aaa", "30/05/2020 20:08\n"], 
	["2", "fff", "30/05/2020 20:08\n"], 
	["3", "vvv", "30/05/2020 20:09\n"], 
	["4", "This is my new post", "30/05/2020 23:05\n"], 
	["5", "This is post number five, lets look what happens!!", "30/05/2020 23:07\n"], 
	["6", "One more, just for checking how it works, and look if we have some bugs...", "30/05/2020 23:09\n"]
]

def self.hash_maker columns, data
	data.collect { |small_arr| { 
		@columns[0] => small_arr[0].strip, 
		@columns[1] => small_arr[1].strip, 
		@columns[2] => small_arr[2].strip 
	} }
end

@result_posts = hash_maker @columns, @data 

puts @result_posts.inspect
puts
puts @result_posts