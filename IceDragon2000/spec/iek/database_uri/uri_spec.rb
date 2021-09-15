__END__
require_relative '../spec_helper'
require "iek/database_uri/uri/common"

describe URI do
  context "#parse" do
    it "should parse a valid uri" do
      URI.parse("/my/valid/ur")
    end

    it "should parse a valid uri with a query" do
      URI.parse("/my/valid/ur?hat=red")
    end

    it "should parse a valid uri with a reference" do
      URI.parse("/my/valid/ur#id")
    end

    it "should parse a valid uri with a query and reference" do
      URI.parse("/my/valid/ur?bam=wam#id")
    end
  end
end
