require 'test/unit'

framework "Cocoa"
require 'Classes/Views/FuzzyCell'

class FuzzyCellTest < Test::Unit::TestCase
  
  def test_extracts_suffix
    cell = FuzzyCell.alloc.init
    cell.setObjectValue("a/b/c/d.haml")
    assert_equal "HAML", cell.filetypeSuffix
  end
  
end
