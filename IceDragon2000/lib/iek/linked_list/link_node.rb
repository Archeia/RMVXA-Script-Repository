class LinkNode
  attr_accessor :value
  attr_accessor :nxt
  attr_accessor :prv

  include Enumerable

  def initialize(value)
    @value = value
    @nxt = nil
    @prv = nil
  end

  def each(&block)
    yield self
    @nxt.each(&block) if @nxt
  end

  def shift
    node = first
    first = node.nxt
    first.prv = nil
    node.nxt = nil
    node
  end

  def pop
    node = last
    last = node.prv
    last.nxt = nil
    node.prv = nil
    node
  end

  def insert(node)
    @prv.nxt = node.first if @prv
    node.first.prv = @prv
    node.last.nxt = self
    node
  end

  def delete
    @nxt.prv = @prv if @nxt
    @prv.nxt = @nxt if @prv
    self
  end

  def append(node)
    nxt = @nxt
    top = self
    while nxt
      top = nxt
      nxt = nxt.nxt
    end
    node = node.first
    top.nxt = node
    node.prv = top
    node
  end

  def prepend(node)
    prv = @prv
    top = self
    while prv
      top = prv
      prv = prv.prv
    end
    node = node.last
    top.prv = node
    node.nxt = top
    node
  end

  def last
    if @nxt
      @nxt.last
    else
      self
    end
  end

  def first
    if @prv
      @prv.first
    else
      self
    end
  end

  def succ
    @nxt || self
  end

  def pred
    @prv || self
  end

  def loop!
    f, l = first, last
    first.prv = l
    last.nxt = f
  end

  def snap
    @nxt.prv = nil if @nxt
    @nxt = nil
    self
  end

  def detach
    @prv.next = nil if @prv
    @prv = nil
    self
  end
end
