require 'test/unit'

require 'Classes/Models/FuzzyRecord'

class FuzzyRecordTest < Test::Unit::TestCase

  test "creates valid record" do
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("aaa", filePath:"bbb")
    assert_equal "aaa", fuzzyRecord.projectRoot
  end
  
  test "finds matching record with fuzzy search" do
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    assert fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    expectedRanges = [NSMakeRange(0,1),  # b
                      NSMakeRange(5,2),  # /w
                      NSMakeRange(11,2), # /s
                      NSMakeRange(19,3)] # .rb
    assert_equal expectedRanges, fuzzyRecord.matchedRanges
  end
  
  test "rejects if fuzzy search fails partially" do
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/x")
    assert_nil arrayOfMatchingRanges
  end
  
  test "rejects failed match" do
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("x/y/z")
    assert_nil arrayOfMatchingRanges
  end
  
  test "calculates score" do
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    assert_equal 35, fuzzyRecord.matchScore
  end
  
end
