## 算法分析及优化 —— by 炜爵爷(David Zhang)

首先只从算法的角度来看这个题（假设都是基于数组操作）。

经过研究，得出以下几种算法：

### 算法1：方向变量模拟法

最简单的方法是直接模拟螺旋的过程，我这里简称它为模拟法。

其中一种算法是设置一个方向变量，根据该变量判断`(x,y)`应该如何变化；顺着方向进行遍历，等到边界的时候，顺时针旋转方向，再继续遍历，直到所有数组元素访问完毕。为了标记哪些元素已经被访问过，根据原二维数组对应生成一个布尔型的标记数组，初始值均为`true`，当访问一个元素后，就将该元素对应的标记位置为`false`。在以上遍历过程中，如果遇到已经访问过的元素，也顺时针改变方向，直到遍历完毕。

算法1函数`snail_flatten_1`，源码如下：

```ruby
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
```

该算法比较好写，易懂；虽然我也进行了优化，但是由于多使用了一个数组，性能上不大理想。于是，我思考用什么方式来代替标志数组，就有了算法2。

### 算法2：区间模拟法

该算法摒弃了标志数组，改用双向区间的方式来标记。其中`[startx..endx]`表示水平方面的输出区间；`[starty..endy]`表示了垂直方向上的输出区间。这样，我们只要在每次转弯的时候计算边界，通过4个循环语句就可以实现。

算法2函数`snail_flatten_2`，源码如下：

```ruby
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
```
 
算法2代码量比算法1少，由于只访问一次数组，性能也估计会提高不少；但是4个循环语句依然不爽，所以就有了算法3。

### 算法3：合并循环模拟法（算法2的优化版）

算法3把算法2的循环语句进行了合并，函数`snail_flatten_3`，源码如下：

```ruby
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
```

3个算法哪个更好，后面会通过实验来观察。但是由于以上算法都是模拟螺旋过程，非线性方式访问数组，可能当数组长度比较大的时候，会导致一定的效率低下，所以需要有一种非模拟算法来对比观察。

### 算法4：数学规律定位法

我们能不能根据`(x,y)`坐标得到对应的螺旋序号`t(x,y)`呢。

回到螺旋上，我们发现，其实`n*n`的螺旋可以分割成若干个正方形。其中最外面那层是一个边长为`n`的正方形，然后往内第二层是一个边长为`(n-2)`的正方形，再往内是一个`(n-4)`的正方形，以此类推，当第`i (i=0,1,2...)`层的时候，是一个边长为`(n-2i)`的正方形。

这第`i`个正方形的4个顶点坐标为：

    (i,i)--------------(i, n-i-1)
    |                           |
    |                           |
    |                           |
    |                           |
    (n-i-1, i)--------(n-i-1, n-i-1)

对于给定的坐标`(x,y)`，若它落在某个这样的正方形上，若该正方形居于第`k`层，则显然：

    k = min (x, y, n-1-x, n-1-y)

而该正方形外的所有正方形的元素总个数`t0`为:

    t0 = 4(n-1) + 4(n-2-1) + ... + 4(n-2(k-1)-1)
       = 4k(n-1+n-2k+1)/2
       = 4k(2n-2k)/2
       = 4k(n-k)

因此，

    t(k,k) = t0+1 = 4k(n-k)+1

现在我们可以计算`t(x,y)`了。

若顺着第`k`层正方形的边移动，

若`x<=y`，

    t(x,y) = t(k,k)+(x-k)+(y-k) = 4k(n-k)+1+(x+y-2k)

若`x>y`，

    t(x,y) = t(k+1,k+1)-(x-k)-(y-k) = 4(k+1)(n-(k+1))+1-(x+y-2k)

因此我们得到算法4的函数`snail_flatten_4`，源码如下：

```ruby
  def snail_flatten_4
    arr = []
    (0..size - 1).each do |x|
      (0..x - 1).each do |y|
        k = y < size - 1 - x ? y : size - 1 - x
        k += 1
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
```

### 比较：4种算法运行实际时间

用`benchmark`做的比较，用`rand`函数产生随机`n*n`数组，其中`n`为5000，结果如下：

    creating random array...
    n = 10000
                               user     system      total        real
    snail_flatten 1      146.760000  14.790000 161.550000 (219.253572)
    snail_flatten 2       33.500000   6.810000  40.310000 ( 52.996302)
    snail_flatten 3       34.730000   5.140000  39.870000 ( 61.145846)
    snail_flatten 4       52.890000  15.710000  68.600000 (196.598875)

算法1、2、3的运行结果与以上分析的没有大的差别，果然是算法2、3都比较快些。然而算法4的运行结果似乎离估计的出入不小，猜测可能要在数据量很大的情况下才可能体现优势；具体原因，有时间再查。

## Ruby 优化的思考

以上的算法中，如果使用`Hash`来代替`Array`的操作，或许可以获取更好的运行效率。由于时间有限，未做验证，以后有机会可以进行。

## 程序说明

运行测试：

    ruby test/snail_flatten_test.rb

运行性能比较：

    ruby bench.rb