class DatabaseUri
  # Taken from ruby stdlib ruby/2.1.0/cgi/core.rb
  @@accept_charset = "UTF-8" unless defined?(@@accept_charset)

  # URL-encode a string.
  #   url_encoded_string = CGI::escape("'Stop!' said Fred")
  #      # => "%27Stop%21%27+said+Fred"
  def self.escape(string)
    encoding = string.encoding
    string.b.gsub(/([^ a-zA-Z0-9_.-]+)/) do |m|
      '%' + m.unpack('H2' * m.bytesize).join('%').upcase
    end.tr(' ', '+').force_encoding(encoding)
  end

  # URL-decode a string with encoding(optional).
  #   string = CGI::unescape("%27Stop%21%27+said+Fred")
  #      # => "'Stop!' said Fred"
  def self.unescape(string,encoding=@@accept_charset)
    str = string.tr('+', ' ').b.gsub(/((?:%[0-9a-fA-F]{2})+)/) do |m|
      [m.delete('%')].pack('H*')
    end.force_encoding(encoding)
    str.valid_encoding? ? str : str.force_encoding(string.encoding)
  end

  def self.parse_query(query)
    params = {}
    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split('=',2).collect{|v| unescape(v) }

      next unless key

      params[key] ||= []
      params[key].push(value) if value
    end

    params.default=[].freeze
    params
  end
  #/ ruby/2.1.0/cgi/core.rb

  def self.parse(str)
    new URI.parse(str)
  end

  attr_accessor :uri

  def initialize(uri)
    @uri = uri
  end

  def path
    @uri.path
  end

  def data
    case path
    when %r"\A\/(\S+)/(\d+)(/\S+)+\z"
      return 3, $1, $2, $3.split("/").map(&:presence).compact
    when %r"\A\/(\S+)/(\d+)\z"
      return 2, $1, $2
    when %r"\A\/(\S+)\z"
      return 1, $1
    end

    return -1
  end

  def object
    n, *a = data

    case n
    when 1
      base, = a
      obj = Database[base]
    when 2
      base, id, = a
      obj = Database[base][id]
    when 3
      base, id, path = a
      obj = Database[base][id]
      obj = path.inject(obj) do |n, o|
        o.send(n)
      end
      obj
    else
      nil
    end
  end
end
