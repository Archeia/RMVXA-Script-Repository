__END__
require_relative '../spec_helper'
require "iek/database_uri/uri/common"
require "iek/database_uri/uri/generic"
require "iek/database_uri/database_uri"

describe DatabaseUri do
  context ".parse" do
    it "should parse a db-uri" do
      DatabaseUri.parse("/items/1#name")
    end
  end

  context "#data" do
    it "should return object" do
      DatabaseUri.parse("/items/1#name").data
      DatabaseUri.parse("/items/1/name").data
      DatabaseUri.parse("/items/1/damage/type").data
    end
  end
end
