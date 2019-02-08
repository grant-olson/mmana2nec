require 'mmana2nec'
require 'optimist'

module Mmana2nec
  module CLI
    def self.mmana2nec

      opts = Optimist::options do
        opt :frequency, "Specify default frequency in Mhz", :type => :float
      end

      file_names = ARGV

      raise "NEED FILE" if file_names.empty?

      file_names.each do |file_name|

        Dir.glob(file_name).each do |file_name|
          intermediate_format = Mmana2nec::MmanaProcessor.new.process_file(file_name)

          new_file = file_name.split(".")[0] + ".nec"
          Mmana2nec::NecProcessor.write(intermediate_format, new_file)
        end
      end

    end
  end
end
