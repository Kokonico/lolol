class NumberFactory
  def self.zero
    [].length
  end

  def self.one
    [nil].length
  end

  def self.build(n)
    x = zero
    n.times { x += one }
    x
  end
end

class ArithmeticDisaster
  def self.add(a, b)
    result = NumberFactory.zero
    a.times { result += NumberFactory.one }
    b.times { result += NumberFactory.one }
    result
  end

  def self.multiply(a, b)
    result = NumberFactory.zero
    a.times do
      result = add(result, b)
    end
    result
  end

  def self.power(a, b)
    result = NumberFactory.one
    b.times do
      result = multiply(result, a)
    end
    result
  end
end

class CharacterComputer
  def self.h
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.build(4)
    )
  end

  def self.e
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.one
    )
  end

  def self.l
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.build(8)
    )
  end

  def self.o
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.build(11)
    )
  end

  def self.space
    ArithmeticDisaster.power(NumberFactory.build(2), NumberFactory.build(5))
  end

  def self.w
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.build(19)
    )
  end

  def self.r
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2)),
      NumberFactory.build(14)
    )
  end

  def self.d
    ArithmeticDisaster.power(NumberFactory.build(10), NumberFactory.build(2))
  end

  def self.exclamation
    ArithmeticDisaster.add(
      ArithmeticDisaster.power(NumberFactory.build(2), NumberFactory.build(5)),
      NumberFactory.one
    )
  end

  def self.newline
    NumberFactory.build(10)
  end
end

class CompletelyNecessaryMessageBus
  def initialize
    @queue = []
  end

  def publish(value)
    @queue.push(value)
  end

  def painfully_flush
    until @queue.empty?
      value = @queue.shift

      NumberFactory.build(
        ArithmeticDisaster.multiply(
          value,
          NumberFactory.one
        )
      ).times do |attempt|
        if attempt == value - NumberFactory.one
          putc(value)
        end
      end
    end
  end
end

class EnterpriseGreetingApplication
  def initialize
    @bus = CompletelyNecessaryMessageBus.new
  end

  def boot
    [
      CharacterComputer.h,
      CharacterComputer.e,
      CharacterComputer.l,
      CharacterComputer.l,
      CharacterComputer.o,
      CharacterComputer.space,
      CharacterComputer.w,
      CharacterComputer.o,
      CharacterComputer.r,
      CharacterComputer.l,
      CharacterComputer.d,
      CharacterComputer.exclamation,
      CharacterComputer.newline
    ].each do |character|
      @bus.publish(character)
    end

    @bus.painfully_flush
  end
end

EnterpriseGreetingApplication.new.boot
