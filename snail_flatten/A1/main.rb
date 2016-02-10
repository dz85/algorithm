require_relative 'lib/snail_flatten'

a = [
  [1, 2],
  [3, 4]
]
b = [1, 2, 4, 3]

(1..4).each do |i|
  puts a.snail_flatten(i) <=> b
  puts a.snail_flatten(i).to_s
end

a = [
  [1, 2, 3],
  [4, 5, 6],
  [7, 8, 9]
]
b = [1, 2, 3, 6, 9, 8, 7, 4, 5]

(1..4).each do |i|
  puts a.snail_flatten(i) <=> b
  puts a.snail_flatten(i).to_s
end

a = [
  [12, 32, 9, 11, 34],
  [8, 54, 76, 23, 7],
  [27, 18, 25, 9, 43],
  [11, 23, 78, 63, 19],
  [9, 22, 56, 31, 5]
]
b = [12, 32, 9, 11, 34, 7, 43, 19, 5, 31, 56, 22, 9, 11, 27, 8, 54, 76, 23, 9, 63, 78, 23, 18, 25]

(1..4).each do |i|
  puts a.snail_flatten(i) <=> b
  puts a.snail_flatten(i).to_s
end