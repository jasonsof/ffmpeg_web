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

    # transcodes the file and returns an io pipe object
    def transcode(output_size=nil)
      progress_read, progress_write = IO::pipe
      pid = Process.fork do
        progress_read.close

        if output_size.nil?
         crf_encode(progress_write)
        else
          two_pass_encode(output_size, progress_write)
        end
      end

      progress_write.close

      progress_read
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

      def two_pass_encode(output_size, progress_write)
        output_size_in_kilobits = output_size * 8192      
        audio_bitrate = 128
        total_bitrate = output_size_in_kilobits / self.duration
        video_bitrate = total_bitrate - audio_bitrate

        first_pass = "ffmpeg -y -i '#{@input}' -movflags faststart -c:v libx264 -preset slow -b:v #{video_bitrate}k -an -pass 1 -f mp4 /dev/null"
        second_pass = "ffmpeg -y -i '#{@input}' -movflags faststart -c:v libx264 -preset slow -b:v #{video_bitrate}k -c:a libfaac -b:a #{audio_bitrate}k -pass 2 '#{@output}.mp4'"

        pid, read = do_pass(first_pass)
        log_progress(read, progress_write, 1, 2)
        pid, status = Process.waitpid2(pid)

        pid, read = do_pass(second_pass)
        log_progress(read, progress_write, 2, 2)
        pid, status = Process.waitpid2(pid)
        status.exitstatus
      end

      def crf_encode(progress_write)
        pid, read = do_pass("ffmpeg -y -i '#{@input}' -movflags faststart -c:v libx264 -preset slow -crf 20 -c:a libfaac '#{output}.mp4'")
        log_progress(read, progress_write, 1, 1)

        pid, status = Process.waitpid2(pid)
        status.exitstatus
      end

      def do_pass(cmd)
        read, write = IO::pipe
        pid = Process.fork do
          read.close

          $stderr.reopen(write)
          $stdout.reopen(write)
          exec(cmd)
        end
        write.close

        [pid, read]
      end

      def log_progress(input_stream, output_stream, current_pass, number_of_passes)
        duration = 0.00 #milliseconds
        elapsed = 0.00 #milliseconds

        while line = input_stream.gets
          if line =~ /Duration: (\d{2}):(\d{2}):(\d{2}).(\d{2})/ && duration == 0.00
            duration = ($~[1].to_i * 60 * 60 * 1000) + ($~[2].to_i * 60 * 1000) + ($~[3].to_i * 1000) + $~[4].to_i
            break
          end     
        end

        while line = input_stream.gets("\r")
          line = line.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, :replace => '') if line
          if line =~ /time=(\d{2}):(\d{2}):(\d{2}).(\d{2})/
            elapsed = ($~[1].to_i * 60 * 60 * 1000) + ($~[2].to_i * 60 * 1000) + ($~[3].to_i * 1000) + $~[4].to_i

            pass_progress = (elapsed.to_f / duration.to_f) * 100
            if number_of_passes > 1 && current_pass > 1
              progress = (pass_progress / number_of_passes) + (100 / number_of_passes)
            elsif number_of_passes > 1 && current_pass == 1
              progress = pass_progress / number_of_passes
            else
              progress = pass_progress
            end
            
            output_stream.puts progress.round(2).to_s + "%"
          end
        end
      end      
  end
end
