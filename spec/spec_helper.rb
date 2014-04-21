require 'ffmpeg_web'

RSpec.configure do |config|
end

def fixture_path
  @fixture_path ||= File.join(File.dirname(__FILE__), 'fixtures')
end

def base_path
  @base_path ||= Dir.pwd#File.expand_path("..",Dir.pwd)
end