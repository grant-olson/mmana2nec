module Mmana2nec
  class IntermediateFormat
    attr_accessor :wires, :sources, :loads, :segmentation, :frequency
    def initialize
      @wires = []
      @sources = []
      @loads = []
      @segmentation = []
      @frequency ||= 7.0
    end
  end
end
