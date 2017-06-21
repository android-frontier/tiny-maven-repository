require 'nokogiri'
require 'digest/md5'
require 'digest/sha1'

class Artifact
  attr_reader :metadata

  def initialize(metadata)
    @metadata = Nokogiri.parse(metadata)
  end

  # @return [String]
  def group_id
    @metadata.css('metadata groupId').first.text
  end

  # @return [String]
  def artifact_id
    @metadata.css('metadata artifactId').first.text
  end

  # @return [String]
  def version
    version = @metadata.css('metadata versioning versions version,snapshot').last
    if version.name == 'snapshot'
      'SNAPSHOT'
    else
      version.text
    end
  end

  # @return [Boolean]
  def empty?
    @metadata.css('metadata versioning versions version,snapshot').empty?
  end

  # @return [Time]
  def updated_at
    Time.strptime(@metadata.css('metadata versioning lastUpdated').first.text, '%Y%m%d%H%M%S')
  end

  # @return [String]
  def path
    group_id.gsub(/\./, '/') + '/' + artifact_id + '/'
  end

  def remove_version(version)
    @metadata.css("versions version:contains('#{version}')").remove
  end

  # @return [String]
  def to_xml
    @metadata.to_s
  end

  def save(s3_storage, metadata_file)
    xml = to_xml
    s3_storage.put_object(metadata_file, StringIO.new(xml))
    s3_storage.put_object("#{metadata_file}.md5", StringIO.new(Digest::MD5.hexdigest(xml)))
    s3_storage.put_object("#{metadata_file}.sha1", StringIO.new(Digest::SHA1.hexdigest(xml)))
  end

  # @return [String]
  def as_dependency
    "#{group_id}:#{artifact_id}:#{version}"
  end
end
