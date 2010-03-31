require 'test/unit'

require 'Classes/Models/FuzzyRecord'
require 'Classes/Helpers/Array+GCD'

class FuzzyRecordTest < Test::Unit::TestCase

  test "creates valid record" do
    fuzzyRecord = createRecordWithProjectRoot("aaa",
                                              filePath:"bbb")
    assert_equal "aaa", fuzzyRecord.projectRoot
  end

  test "finds matching record with fuzzy search" do
    fuzzyRecord = createRecordWithProjectRoot("~/tmp/demo",
                                              filePath:"bacon/wagyu/seasalt.rb")
    assert fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    expectedRanges = [NSMakeRange(0,1),  # b
                      NSMakeRange(5,2),  # /w
                      NSMakeRange(11,2), # /s
                      NSMakeRange(19,3)] # .rb
    assert_equal expectedRanges, fuzzyRecord.matchedRanges
  end

  test "rejects if fuzzy search fails partially" do
    fuzzyRecord = createRecordWithProjectRoot("~/tmp/demo",
                                              filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/x")
    assert_nil arrayOfMatchingRanges
  end

  test "rejects failed match" do
    fuzzyRecord = createRecordWithProjectRoot("~/tmp/demo",
                                              filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("x/y/z")
    assert_nil arrayOfMatchingRanges
  end

  test "calculates score" do
    fuzzyRecord = createRecordWithProjectRoot("~/tmp/demo",
                                              filePath:"bacon/wagyu/seasalt.rb")
    arrayOfMatchingRanges = fuzzyRecord.fuzzyInclude?("b/w/s.rb")
    assert_equal 35, fuzzyRecord.matchScore
  end

  test "resets object" do
    fuzzyRecord = createRecordWithProjectRoot("~/tmp/demo",
                                              filePath:"bacon/wagyu/seasalt.rb")
    fuzzyRecord.resetMatches!
    assert_equal FuzzyRecord::MAX_SCORE, fuzzyRecord.matchScore
    assert_nil fuzzyRecord.matchedRanges
  end

  test "resets with GCD" do
    records = FuzzyRecord.recordsWithProjectRoot(File.expand_path("../"))
    filteredRecords = FuzzyRecord.filterRecords(records,
                                                forString:"Cell")
    assert_not_nil filteredRecords.first.matchedRanges
    FuzzyRecord.resetMatchesForRecords!(filteredRecords)
    assert_nil filteredRecords.first.matchedRanges
  end

  def createRecordWithProjectRoot(projectRoot, filePath:filePath)
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot(projectRoot, filePath:filePath)
  end

end
