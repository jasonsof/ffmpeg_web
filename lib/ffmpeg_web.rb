require "ffmpeg_web/version"

module FFmpegWeb
  class Transcoder
    attr_accessor :input, :output

    def initialize(input, output)
      raise "Input file does not exist" if !File.exists?(input)
      raise "Output directory does not exist" if !File.exists?(File.dirname(output))
      raise "File is not a valid movie file" if !is_valid?(input)

      @input = input
      @output = output
    end

    # returns the duration of the video in seconds
    def duration
      read, write = IO::pipe
      pid = Process.fork do
        read.close

        $stderr.reopen(write)
        exec("ffmpeg -y -i '#{@input}'")
      end
      write.close

      #Process.wait(pid)

      ffmpeg_output = read.read
      duration = /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2})/.match(ffmpeg_output)
      duration_in_milliseconds = ($~[1].to_i * 60 * 60) + ($~[2].to_i * 60) + $~[3].to_i + ($~[4].to_i / 1000)
    end

    private
      def is_valid?(input)
        video_stream, audio_stream = nil

        read, write = IO::pipe
        pid = Process.fork do
          read.close

          $stderr.reopen(write)
          exec("ffmpeg -y -i '#{input}'")
        end
        write.close

        #Process.wait(pid)

        ffmpeg_output = read.read
        if match = ffmpeg_output.match(/Video: (.*)$/i)
          video_stream = match.captures.first
        end

        if match = ffmpeg_output.match(/Audio: (.*)$/i)
          audio_stream = match.captures.first
        end

        video_stream && audio_stream
      end
  end
end
