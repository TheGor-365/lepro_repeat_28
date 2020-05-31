# def arraer arr
# 	f.split(/__/)
# 	return f
# end

arr = [

	["1", "aaa", "30/05/2020 20:08\n"], 
	["2", "fff", "30/05/2020 20:08\n"], 
	["3", "vvv", "30/05/2020 20:09\n"], 
	["4", "This is my new post", "30/05/2020 23:05\n"], 
	["5", "This is post number five, lets look what happens!!", "30/05/2020 23:07\n"], 
	["6", "One more, just for checking how it works, and look if we have some bugs...", "30/05/2020 23:09\n"]
]

hh = {}


arr.each_with_index do |sm_arr, i|
	@arr2 = []

	hh[:id] = sm_arr[0]
	hh[:body] = sm_arr[1]
	hh[:date] = sm_arr[2]
	@arr2 << hh

end

puts arr.inspect
puts
puts hh.inspect		
puts
puts @arr2.inspect