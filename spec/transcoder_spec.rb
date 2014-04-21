require 'spec_helper'

describe FFmpegWeb::Transcoder do
  let(:good_input) { "#{fixture_path}/10 seconds.mov" }
  let(:bad_input) { "#{fixture_path}/broken.mp4" }
  let(:output) { "#{fixture_path}/output" }

  describe "#initialize" do
    it "sets the @input variable" do
      transcoder = FFmpegWeb::Transcoder.new(good_input, output)
      expect(transcoder.instance_variable_get(:@input)).to eq good_input
    end
    it "sets the @output variable" do
      transcoder = FFmpegWeb::Transcoder.new(good_input, output)
      expect(transcoder.instance_variable_get(:@output)).to eq output
    end

    context "when the input is an invalid video file" do
      it "raises an exception" do
        expect {
          transcoder = FFmpegWeb::Transcoder.new(bad_input, output)
          }.to raise_exception
      end
    end

    context "when the input does not exist" do
      it "raises an exception" do
        input = "/path/to/nonexistent/input.mov"

        expect {
          transcoder = FFmpegWeb::Transcoder.new(input, output)
        }.to raise_exception
      end
    end

    context "when the output directory does not exist" do
      it "raises an exception" do
        output = "/path/nonexistent/output"

        expect {
          transcoder = FFmpegWeb::Transcoder.new(good_input, output)
        }.to raise_exception
      end
    end
  end

  describe "#duration" do
    context "when the input is a valid video file" do
      it "returns the videos duration in seconds" do
        transcoder = FFmpegWeb::Transcoder.new(good_input, output)
        expect(transcoder.duration).to eq(10)
      end

      it "returns a Fixnum" do
        transcoder = FFmpegWeb::Transcoder.new(good_input, output)
        expect(transcoder.duration).to be_a(Fixnum)
      end
    end
  end

  describe "#transcode" do
    let(:megabyte) { 1024.0 * 1024.0 }

    after(:each) do
      begin
        FileUtils.rm("#{fixture_path}/output.mp4")
        FileUtils.rm("#{base_path}/ffmpeg2pass-0.log")
        FileUtils.rm("#{base_path}/ffmpeg2pass-0.log.mbtree")
      rescue Errno::ENOENT
      end
    end

    context "given an output filesize" do
      it "creates an output file around the size given" do
        desired_output_size_in_mb = 10

        transcoder = FFmpegWeb::Transcoder.new(good_input, output)
        progress_stream = transcoder.transcode(desired_output_size_in_mb)
        while progress = progress_stream.gets
        end

        expect(File.exists?("#{output}.mp4")).to be_true
        output_size = File.size("#{output}.mp4").to_f / megabyte
        expect(output_size).to be_within(1).of(desired_output_size_in_mb)
      end
    end

    context "without given an output filesize" do
      it "creates an output file" do
        transcoder = FFmpegWeb::Transcoder.new(good_input, output)
        progress_stream = transcoder.transcode(10)
        while progress = progress_stream.gets
        end

        expect(File.exists?("#{output}.mp4")).to be_true
      end
    end

    it "returns an IO stream" do
      transcoder = FFmpegWeb::Transcoder.new(good_input, output)
      progress_stream = transcoder.transcode(10)
      expect(progress_stream).to be_an(IO)
    end
  end
end