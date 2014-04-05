require "ffmpeg_web/version"

module FFmpegWeb
  class Transcoder
    attr_accessor :input, :output, :video_info

    def initialize(input, output)
      @input = input
      @output = output
      
      raise "Input file does not exist" if !File.exists?(input)
      raise "Output directory does not exist" if !File.exists?(File.dirname(output))

      @video_info = ffmpeg_info

      raise "File is not a valid movie file" if !is_valid?
    end

    # returns the duration of the video in seconds
    def duration
      duration = /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2})/.match(@video_info)
      duration_in_milliseconds = ($~[1].to_i * 60 * 60) + ($~[2].to_i * 60) + $~[3].to_i + ($~[4].to_i / 1000)
    end

    private
      def ffmpeg_info
        read, write = IO::pipe
        pid = Process.fork do
          read.close

          $stderr.reopen(write)
          exec("ffmpeg -y -i '#{@input}'")
        end
        write.close

        ffmpeg_output = read.read
        ffmpeg_output
      end

      def is_valid?
        video_stream, audio_stream = nil

        if match = @video_info.match(/Video: (.*)$/i)
          video_stream = match.captures.first
        end

        if match = @video_info.match(/Audio: (.*)$/i)
          audio_stream = match.captures.first
        end

        video_stream && audio_stream
      end
  end
end
