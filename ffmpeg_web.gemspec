# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffmpeg_web/version'

Gem::Specification.new do |spec|
  spec.name          = "ffmpeg_web"
  spec.version       = FFmpegWeb::VERSION
  spec.authors       = ["Jason"]
  spec.email         = ["jsofokleous@googlemail.com"]
  spec.summary       = %q{A Ruby wrapper for FFMpeg that allows you to transcode video into a web optimised format. }
  spec.description   = %q{}
  spec.homepage      = "https://github.com/jasonsof/ffmpeg_web"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec" 
end
