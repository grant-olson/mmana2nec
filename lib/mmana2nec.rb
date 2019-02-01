require "mmana2nec/version"

module Mmana2nec
  class Error < StandardError; end

  class IntermediateFormat
    attr_accessor :wires, :sources, :loads, :segmentation
    def initialize
      @wires = []
      @sources = []
      @loads = []
      @segmentation = []
    end
  end

  class MmanaProcessor

    def new_section?
      (lines.empty? || lines[-1].start_with?("***"))
    end

    def extract_data 
      lines.pop.split(",\t").map {|x| x.include?("w") ? x : x.to_f}
    end

    def process_list
      list_contents = []
      list_count = lines.pop.to_i
      until new_section?
        list_contents << extract_data
      end

      if list_contents.length != list_count
        raise "Length check failed"
      end

      list_contents
        
    end
    
    def process_wires
      intermediate_format.wires = process_list.map { |data|
        x1, y1, z1, x2, y2, z2, diameter, segments = data
        {end_one: {x: x1, y: y1, z: z1},
         end_two: {x: x2, y: y2, z: z2},
         diameter: diameter,
         segments: segments
        }
      }
    end

    def process_source
      intermediate_format.sources = process_list.map { |data|
        connection, phase, volts = data
        {connection: connection, phase: phase, volts: volts}
      }
                                                       
    end

    def process_load
      intermediate_format.loads = process_list

      if intermediate_format.loads.length > 0
        raise "Didn't deal with loads yet!"
      end
    end

    def process_segmentation
      intermediate_format.segmentation = extract_data
    end

    def process_g_h_m_r_azel_x
      ground_type, h, m, impedance, azimuth, elevation, x = extract_data
      # Figure this out later!
    end
    
    attr_reader :lines, :intermediate_format
    def process_file file_name

      file = File.open(file_name)

      @lines = file.readlines.map { |x| x.gsub("\r","").gsub("\n", "") }.reverse
      @intermediate_format = IntermediateFormat.new
      #header

      name = lines.pop
      unknown_header_1 = lines.pop
      unknown_header_2 = lines.pop

      while !lines.empty?
        current_section = lines.pop
        if !current_section.start_with?("***")
          raise "BAD FILE FORMAT"
        end

        current_section = current_section[3..-4]
        puts current_section

        section_method = "process_" + current_section.downcase.gsub("/","_")

        send(section_method)
      end

      @intermediate_format
    end
  end
end
