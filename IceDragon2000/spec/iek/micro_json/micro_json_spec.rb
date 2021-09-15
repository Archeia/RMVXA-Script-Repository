require_relative '../spec_helper'
require "iek/micro_json/micro_json"

describe MicroJSON do
  context ".load" do
    it "should load valid JSON" do
      result = subject.load(%Q(
        {
          "toad": "Some Mushroom Dude",
          "and": {
            "it": "was",
            "written": ["in", "the", "book", "of", "life"]
          },
          "that": 1,
          "is": false,
          "2": true,
          "that": [
            "7",
            8,
            "9"
          ]
        }
        ))

      expect(result).to eq({
        "toad" => "Some Mushroom Dude",
        "and" => {
          "it" => "was",
          "written" => ["in", "the", "book", "of", "life"]
        },
        "that" => 1,
        "is" => false,
        "2" => true,
        "that" => ["7", 8, "9"]
      })
    end
  end

  context ".dump" do
    it "should dump object to JSON" do
      subject.dump({
        "all" => "you gotta do is",
        "jump" => ["to", "the", "sky"],
        0 => "Say you don't give a ****",
        true => "And receive bacon",
        "and" => [7, "still", 8, 9]
      })
    end
  end
end
