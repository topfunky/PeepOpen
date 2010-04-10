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

  test "resets many records" do
    records = [
               createRecordWithProjectRoot(File.expand_path("."),
                                           filePath:"Classes/Views/FuzzyCell.rb"),
               createRecordWithProjectRoot(File.expand_path("."),
                                           filePath:"Classes/Models/FuzzyRecord.rb")
              ]
    filteredRecords = FuzzyRecord.filterRecords(records,
                                                forString:"Cell")
    assert_not_nil filteredRecords.first.matchedRanges
    FuzzyRecord.resetMatchesForRecords!(filteredRecords)
    assert_nil filteredRecords.first.matchedRanges
  end

  test "filters with best strategy" do
    record = createRecordWithProjectRoot(File.expand_path("."),
                                         filePath:"Classes/Views/FuzzyCell.rb")
    assert record.fuzzyInclude?("cell")
    assert_equal 19, record.matchScore
  end

  def createRecordWithProjectRoot(projectRoot, filePath:filePath)
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot(projectRoot, filePath:filePath)
  end

  # UNIMPLEMENTED: Should return one contiguous match when searching
  # Classes/Controllers/AppDelegate.rb for "appde"
  
  # UNIMPLEMENTED: Should find files in project root (class method)
  
  ##
  # Returns an array of records for this project.

  def createRecords
    FuzzyRecord.recordsWithProjectRoot(File.expand_path("."))
  end

end
