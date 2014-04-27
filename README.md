# FfmpegWeb

A wrapper for FFMpeg that allow you to transcode video into a web optimised format.  
The transcoder provides two modes of encoding depending on your needs:
- Contant Rate Factor (CRF) which will give you the best output quality possible at the expense of potentially having a larger file size
- Two Pass which allows you to specify the desired output file size of the transcode at the expense of potentially having a lower quality 

To find out more about this, take a look at FFmpeg's wiki page about it - https://trac.ffmpeg.org/wiki/x264EncodingGuide

Other things to note:
- the output file will overwrite any file with the same name without warning
- the moov atom will be moved to the beginning of the file to allow web playback to begin before the whole file has finished loading
- FFmpeg must be installed 

## Installation

Add this line to your application's Gemfile:

    gem 'ffmpeg_web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffmpeg_web

## Usage

Initialize a transcode:

    transcoder = FFmpegWeb::Transcoder.new("/path/to/file.avi", "/where/to/output/file")
You don't need to include a file extension to the output file (just a name) since .mp4 will be added by default.

Begin the transcode using default CRF mode:

    transcoder.transcode
Begin the transcode using Two Pass mode:

    transcoder.transcode(desired_output_size_in_mb)

The transcode method returns an IO pipe object that will stream back the progress percentage of the job.

    progress_stream = transcoder.transcode(50)
    while progress = progress_stream.gets
        puts progress
    end

The transcode method spawns a child process and is non-blocking

## Contributing

1. Fork it ( http://github.com/<my-github-username>/ffmpeg_web/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
