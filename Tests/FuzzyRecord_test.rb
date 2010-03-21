require 'test/unit'

require 'Classes/Models/FuzzyRecord'

class FuzzyRecordTest < Test::Unit::TestCase

  def test_creates_from_filePath
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("aaa", filePath:"bbb")
    assert_equal "aaa", fuzzyRecord.projectRoot
  end

  def test_finds_matching_record_with_fuzzy_search
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    expectedRanges = [NSMakeRange(0,1),  # b
                      NSMakeRange(5,2),  # /w
                      NSMakeRange(11,2), # /s
                      NSMakeRange(19,3)] # .rb
    assert_equal expectedRanges, arrayOfMatchingRanges
  end

  def test_rejects_if_fuzzy_search_fails_partially
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/x")
    assert_nil arrayOfMatchingRanges
  end

  def test_rejects_failed_match
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("x/y/z")
    assert_nil arrayOfMatchingRanges
  end
  
  def test_calculates_score
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot("~/tmp/demo", filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    assert_equal 35, fuzzyRecord.matchScore
  end
  
end
