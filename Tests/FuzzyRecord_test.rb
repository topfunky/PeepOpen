require 'test/unit'

$: << 'Classes/Helpers'

require 'Classes/Helpers/Constants'
require 'Classes/Operations/PathOperation'
require 'Classes/Controllers/AppDelegate'
require 'Classes/Controllers/FuzzyTableViewController'
require 'Classes/Models/FuzzyRecord'
require 'Classes/Helpers/Array+GCD'

class FuzzyRecordTest < Test::Unit::TestCase

  def setup
    NSUserDefaults.standardUserDefaults.registerDefaults(AppDelegate.registrationDefaults)
  end

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
                                                forString:"Cell",
                                                whitespaceSearchCharacter:"")
    assert_not_nil filteredRecords.first.matchedRanges
    FuzzyRecord.resetMatchesForRecords!(filteredRecords)
    assert_nil filteredRecords.first.matchedRanges
  end

  test "filters with best strategy" do
    record = createRecordWithProjectRoot(File.expand_path("."),
                                         filePath:"Classes/Views/FuzzyCell.rb")
    assert record.fuzzyInclude?("cell")
    assert_equal 5, record.matchScore
  end

  test "finds files" do
    records = createRecords
    assert_in_delta 50, records.length, 400
  end

  test "filters on filename first if it matches" do
    records = createRecords
    filteredRecords = FuzzyRecord.filterRecords(records,
                                                forString:"del",
                                                whitespaceSearchCharacter:"")
    bestMatchingFile = filteredRecords.first
    assert_equal "Classes/Controllers/AppDelegate.rb", bestMatchingFile.filePath
  end

  test "caches project records" do
    records = createRecords
    assert_kind_of NSMutableArray, FuzzyRecord.cachedRecordsForProjectRoot(".")
  end

  test "ignores spaces in search string" do
    records = createRecords
    assert_in_delta 85, FuzzyRecord.filterRecords(records, forString:"c m", whitespaceSearchCharacter:"").length, 5
  end

  test "stores recently opened records" do
    records = createRecords
    record = records.last
    assert_not_equal record, FuzzyRecord.filterRecords(records,
                                                       forString:"",
                                                       whitespaceSearchCharacter:"").first
    FuzzyRecord.storeRecentlyOpenedRecord(record)
    FuzzyRecord.storeRecentlyOpenedRecord(records[-2])

    assert_equal record, FuzzyRecord.filterRecords(records,
                                                   forString:"",
                                                   whitespaceSearchCharacter:"").first
  end

  test "discovers project root from file" do
    projectRoot = FuzzyRecord.discoverProjectRootForDirectoryOrFile(__FILE__)
    assert_equal(ENV['SOURCE_ROOT'], projectRoot)
  end

  test "discovers project root from directory" do
    projectRoot = FuzzyRecord.discoverProjectRootForDirectoryOrFile(ENV['SOURCE_ROOT'])
    assert_equal(ENV['SOURCE_ROOT'], projectRoot)
  end

  test "raises error on failure to find project root" do
    testFilePath = "/tmp/PeepOpen.test.file.txt"
    system "touch #{testFilePath}"
    assert_raise(FuzzyRecord::ProjectRootNotFoundError) {
      projectRoot = FuzzyRecord.discoverProjectRootForDirectoryOrFile(testFilePath)
    }
  end

  def createRecordWithProjectRoot(projectRoot, filePath:filePath)
    fuzzyRecord = FuzzyRecord.alloc.
      initWithProjectRoot(projectRoot, filePath:filePath)
  end

  ##
  # Returns an array of records for this project.

  def createRecords
    FuzzyRecord.recordsForProjectRoot(".", withFuzzyTableViewController:FuzzyTableViewController.new)
  end

end
