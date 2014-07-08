require 'test_helper'

class ArtifactListTest < ActiveSupport::TestCase
  test "new" do
    l = ArtifactList.new('test/fixtures')

    assert { l.count == 1 }
  end
end
