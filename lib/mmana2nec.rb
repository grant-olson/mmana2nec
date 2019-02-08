require "mmana2nec/version"

module Mmana2nec
  class Error < StandardError; end
end

require 'mmana2nec/intermediate_format'
require 'mmana2nec/nec_processor'
require 'mmana2nec/mmana_processor'
require 'mmana2nec/cli'
