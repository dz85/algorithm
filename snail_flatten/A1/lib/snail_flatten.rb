require_relative 'snail_flatten/version'

# 数组螺旋化模块
module SnailFlatten
  # 将数组螺旋化输出
  def snail_flatten(t)
    unless snail_flatten?
      # TODO: 这里就不把错误处理展开了
      fail 'Invaild Input!'
      # return nil
    end

    case t
    when 1
      snail_flatten_1
    when 2
      snail_flatten_2
    when 3
      snail_flatten_3
    when 4
      snail_flatten_4
    end
  end

  private

  # 判断是不是符合条件的数组
  def snail_flatten?
    # TODO: 这里暂时不对每种错误情况做详细处理
    return false unless is_a?(Array) && size > 0

    each do |arr|
      return false unless arr.is_a?(Array) && arr.size == size

      arr.each do |a|
        return false if a.nil?
      end
    end
    true
  end

  def clone_true
    result = []
    each do |line|
      result_line = []
      line.size.times { result_line << true }
      result << result_line
    end
    result
  end

  DIRS = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  def snail_flatten_1
    arr = []
    t = x = y = 0
    flags = clone_true

    while arr.size < size**2
      arr << self[x][y]
      flags[x][y] = false
      nx = x + DIRS[t][0]
      ny = y + DIRS[t][1]
      t = (t + 1) % 4 unless nx.between?(0, size - 1) && ny.between?(0, size - 1) && flags[nx][ny]
      x += DIRS[t][0]
      y += DIRS[t][1]
    end
    arr
  end

  def snail_flatten_2
    arr = []
    startx = starty = 0
    endx = endy = size - 1

    while startx <= endx && starty <= endy
      (starty..endy).each { |y| arr << self[startx][y] }
      startx += 1

      (startx..endx).each { |x| arr << self[x][endy] }
      endy -= 1

      endy.downto(starty) { |y| arr << self[endx][y] }
      endx -= 1

      endx.downto(startx) { |x| arr << self[x][starty] }
      starty += 1
    end
    arr
  end

  def snail_flatten_3
    arr = []
    level = size / 2
    i = 0
    (0..level - 1).each do |x|
      len = size - 1 - 2 * x
      endy = size - 1 - x
      arr[i] = self[x][x]
      arr[i + len] = self[x][endy]
      arr[i + 2 * len] = self[endy][endy]
      arr[i + 3 * len] = self[endy][x]
      i += 1

      j = i + 4 * len - 2
      (x + 1..endy - 1).each do |y|
        arr[i] = self[x][y]
        arr[i + len] = self[y][endy]
        arr[j] = self[y][x]
        arr[j - len] = self[endy][y]
        i += 1
        j -= 1
      end
      i += 3 * len
    end
    arr[size**2 - 1] = self[level][level] if size.odd?
    arr
  end

  def snail_flatten_4
    arr = []
    (0..size - 1).each do |x|
      (0..x - 1).each do |y|
        k = (y < size - 1 - x ? y : size - 1 - x) + 1
        t = 4 * k * (size - k) - (x + y - 2 * (k - 1))
        arr[t] = self[x][y]
        # puts "t: #{t}; x: #{x}; y: #{y}"
      end
      # puts "-"
      (x..size - 1).each do |y|
        k = x < size - 1 - y ? x : size - 1 - y
        t = 4 * k * (size - k) + (x + y - 2 * k)
        arr[t] = self[x][y]
        # puts "t: #{t}; x: #{x}; y: #{y}"
      end
    end
    arr
  end
end

Array.send(:include, SnailFlatten)