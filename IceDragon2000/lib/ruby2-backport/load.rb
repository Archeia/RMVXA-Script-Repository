module RubyHelper
  def self.empty_or_with_content(*args)
    if args.empty?
      yield
    else
      result = args.compact
      if !result.empty?
        yield
      end
    end
  end
end

class Module
  alias :define_method_no_symbol :define_method
  def define_method(*args, &block)
    define_method_no_symbol(*args, &block)
    args.first
  end

  alias :define_singleton_method_no_symbol :define_singleton_method
  def define_singleton_method(*args, &block)
    define_singleton_method_no_symbol(*args, &block)
    args.first
  end

  alias :public_no_symbol :public
  def public(*args)
    RubyHelper.empty_or_with_content args do |argv|
      public_no_symbol(*argv)
    end
  end

  alias :private_no_symbol :private
  def private(*args)
    RubyHelper.empty_or_with_content args do |argv|
      private_no_symbol(*argv)
    end
  end

  alias :protected_no_symbol :protected
  def protected(*args)
    RubyHelper.empty_or_with_content args do |argv|
      protected_no_symbol(*argv)
    end
  end
end
