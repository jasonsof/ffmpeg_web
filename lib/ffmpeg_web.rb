require "ffmpeg_web/version"

module FFmpegWeb
  class Transcoder
    attr_accessor :input, :output

    def initialize(input, output)
      raise "Input file does not exist" if !File.exists?(input)
      raise "Output directory does not exist" if !File.exists?(File.dirname(output))
      @input = input
      @output = output
    end
  end
end
