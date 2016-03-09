class S3Storage
  def initialize(bucket: Rails.application.secrets.s3_bucket)
    @s3 = Aws::S3::Client.new
    @bucket = bucket
  end

  def put_object(path, io)
    @s3.put_object(
      bucket: @bucket,
      key: path.to_s,
      body: io,
    )
  end

  METADATA_FILENAME = 'maven-metadata.xml'

  def each_metadata(prefix, &block)
    @s3.list_objects(bucket: @bucket, prefix: prefix).each do |page|
      page.contents.each do |object|
        if object.key.end_with?(METADATA_FILENAME)
          block.call(object.key)
        end
      end
    end
  end

  def get_object(key)
    @s3.get_object(bucket: @bucket, key: key).body.read
  end

  def exist?(key)
    @s3.get_object(bucket: @bucket, key: key)
    true
  rescue Aws::S3::Errors::NoSuchKey
    false
  end

  def list_artifacts(prefix)
    paths = []
    @s3.list_objects(bucket: @bucket, prefix: "#{prefix}/", delimiter: '/').each do |page|
      page.common_prefixes.each do |common_prefix|
        paths << File.basename(common_prefix.prefix.chomp('/'))
      end
      page.contents.each do |object|
        paths << File.basename(object.key)
      end
    end
    paths
  end

  def rmtree(prefix)
    @s3.list_objects(bucket: @bucket, prefix: prefix).each do |page|
      @s3.delete_objects(
        bucket: @bucket,
        delete: {
          objects: page.contents.map { |object| { key: object.key } },
        },
      )
    end
  end
end
