require 'benchmark'
require_relative 'lib/snail_flatten'

def rand_array(n)
  (1..n).map do
    (1..n).map { rand(n**2).to_i }
  end
end

(10_000..10_002).each do |n|
  b = []
  puts 'creating random array...'
  a = rand_array(n)
  puts "n = #{n}"
  Benchmark.bm(20) do |x|
    x.report('snail_flatten 1') { b << a.snail_flatten(1) }
    x.report('snail_flatten 2') { b << a.snail_flatten(2) }
    x.report('snail_flatten 3') { b << a.snail_flatten(3) }
    x.report('snail_flatten 4') { b << a.snail_flatten(4) }
  end

  result = (0..b.size - 2).map { |i| b[i] <=> b[i + 1] }
  puts result.to_s
end