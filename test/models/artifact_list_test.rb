require 'test_helper'

class ArtifactListTest < ActiveSupport::TestCase
  test "new" do
    s3_storage = Minitest::Mock.new
    s3_storage.expect(:each_metadata, ['maven-metadata.xml']) do |prefix, &block|
      assert { prefix == 'test/fixtures' }
      block.call('test/fixtures/maven-metadata.xml')
    end
    s3_storage.expect(:get_object, File.read('test/fixtures/maven-metadata.xml'), ['test/fixtures/maven-metadata.xml'])

    l = ArtifactList.new('test/fixtures', s3_storage: s3_storage)

    assert { l.count == 1 }

    s3_storage.verify
  end
end
