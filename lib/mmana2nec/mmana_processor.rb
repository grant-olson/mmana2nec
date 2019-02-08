module Mmana2nec
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
      wire_lengths = {}
      wires = []
      
      process_list.each_with_index do |data, index|
        x1, y1, z1, x2, y2, z2, diameter, segments = data

        wire_length = Math.sqrt( (x2-x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2)
        wire_lengths[index] = wire_length
          
        if segments < -1
          raise "Can't process segment type #{segments}"
        end
        
        wires << {end_one: {x: x1, y: y1, z: z1},
                  end_two: {x: x2, y: y2, z: z2},
                  diameter: diameter,
                  segments: segments
        }

      end
      
      wire_lengths = wire_lengths.values.sort
      shortest_wire = wire_lengths[0]
      longest_wire = wire_lengths[-1]

      if longest_wire >= (shortest_wire * 5) #must use shortest wire or smaller as segment size
        segment_length = shortest_wire
      else # can use any segment size
        wavelength = 300.0 / intermediate_format.frequency
        segment_length = wavelength / (2 * 20) # Half wavelength / 20. What is correct fudge factor?
      end
          
      wires.each_with_index do |wire, index|
        if wire[:segments] == -1
          wire_length = wire_lengths[index]
          segments = (wire_length / segment_length).to_i
          segments += 1 if (segments * segment_length) != wire_length
          wire[:segments] = segments
        end
      end
        

      intermediate_format.wires = wires
    end

    def process_source
      intermediate_format.sources = process_list.map { |data|
        connection, phase, voltage = data
        raise "Unexpected connection value #{connection.inspect}" if !connection.start_with?("w")
        wire = connection[1..-2].to_i
        segment = connection[-1]

        # TODO: Figure out center and end once we have real segments
        raise "Don't know how to handle segment type #{segment}" if segment != "b"
        segment = 1
        
        {wire: wire, segment: segment, phase: phase, voltage: voltage}
      }
                                                       
    end

    def process_load
      intermediate_format.loads = process_list

      if intermediate_format.loads.length > 0
        raise "Didn't deal with loads yet!"
      end
    end

    def process_segmentation
      dm1, dm2, sc, ec = extract_data
      intermediate_format.segmentation = {dm1: dm1, dm2: dm2, sc: sc, ec: ec}
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

        section_method = "process_" + current_section.downcase.gsub("/","_")

        send(section_method)
      end

      @intermediate_format
    end
  end
end
