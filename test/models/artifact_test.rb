require 'test_helper'

class ArtifactTest < ActiveSupport::TestCase
  test "as_dependency" do
    metadata = File.read('test/fixtures/maven-metadata.xml')
    artifact = Artifact.new(metadata)
    assert { artifact.group_id == 'com.github.gfx.util' }
    assert { artifact.artifact_id == 'weak-identity-hash-map' }
    assert { artifact.version == '2.0.1' }
    assert { artifact.updated_at == Time.parse('2014-07-07 23:20:56') }
    assert { artifact.as_dependency == 'com.github.gfx.util:weak-identity-hash-map:2.0.1' }
  end

  test "remove_version" do
    metadata = File.read('test/fixtures/maven-metadata.xml')
    artifact = Artifact.new(metadata)

    artifact.remove_version("2.0.1")

    assert { artifact.version == "1.0.0" }
  end
end
