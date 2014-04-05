require 'spec_helper'

describe FFmpegWeb::Transcoder do
  describe "#initialize" do
    it "sets the @input variable" do
      input = "#{fixture_path}/10 seconds.mov"
      output = "#{fixture_path}/output.mp4"

      transcoder = FFmpegWeb::Transcoder.new(input, output)
      expect(transcoder.instance_variable_get(:@input)).to eq input
    end
    it "sets the @output variable" do
      input = "#{fixture_path}/10 seconds.mov"
      output = "#{fixture_path}/output.mp4"

      transcoder = FFmpegWeb::Transcoder.new(input, output)
      expect(transcoder.instance_variable_get(:@output)).to eq output
    end

    context "when the input is an invalid video file" do
      it "raises an exception" do
        input = "#{fixture_path}/broken.mp4"
        output = "#{fixture_path}/output.mp4"

        expect {
          transcoder = FFmpegWeb::Transcoder.new(input, output)
          }.to raise_exception
      end
    end

    context "when the input does not exist" do
      it "raises an exception" do
        input = "/path/to/nonexistent/input.mov"
        output = "/path/to/output"

        expect {
          transcoder = FFmpegWeb::Transcoder.new(input, output)
        }.to raise_exception
      end
    end

    context "when the output directory does not exist" do
      it "raises an exception" do
        input = "/path/to/input.mov"
        output = "/path/nonexistent/output"

        expect {
          transcoder = FFmpegWeb::Transcoder.new(input, output)
        }.to raise_exception
      end
    end
  end

  describe "#duration" do
    context "when the input is a valid video file" do
      it "returns the videos duration in seconds" do
        input = "#{fixture_path}/10 seconds.mov"
        output = "#{fixture_path}/output.mp4"

        transcoder = FFmpegWeb::Transcoder.new(input, output)
        expect(transcoder.duration).to eq(10)
      end

      it "returns a Fixnum" do
        input = "#{fixture_path}/10 seconds.mov"
        output = "#{fixture_path}/output.mp4"

        transcoder = FFmpegWeb::Transcoder.new(input, output)
        expect(transcoder.duration).to be_a(Fixnum)
      end
    end
  end
end