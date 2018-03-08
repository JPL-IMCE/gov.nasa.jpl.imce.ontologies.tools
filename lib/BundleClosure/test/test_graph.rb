require 'graph'
gem 'minitest'
require 'minitest/autorun'

class TestGraph < MiniTest::Test

  def test_to_s
    g = Graph.new
    assert_equal '', g.to_s
  end

end
