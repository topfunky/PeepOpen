require 'test/unit'

require 'Classes/Models/FuzzyRecord'

class FuzzyRecordTest < Test::Unit::TestCase
  def setup
    puts 'setup called'
  end
  
  def teardown
    puts 'teardown called'
  end
  
  def test_creates_from_filePath
    fuzzyRecord = FuzzyRecord.alloc.initWithProjectRoot("aaa", filePath:"bbb")
    assert_equal "aaa", fuzzyRecord.projectRoot
  end
end
