class Fibonacci
  # returns an array of fibonacci numbers
  def self.seq range
    fib_nums = []
    (range).each do |n|
      fib_nums << self.fib(n)
    end
    fib_nums
  end
  
  # golden rule logic
  def self.fib n
    return n if (0..1).include? n
    fib(n - 1) + fib(n - 2)
  end
end

def fib_num n
  Fibonacci.fib n
end

def fib_seq r
  Fibonacci.seq r
end
