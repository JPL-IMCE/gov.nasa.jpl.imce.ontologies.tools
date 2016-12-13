#--
#
#    $HeadURL$
#
#    $LastChangedRevision$
#    $LastChangedDate$
#
#    $LastChangedBy$
#
#    Copyright (c) 2008-2014 California Institute of Technology.
#    All rights reserved.
#
#    Module for generating Makefiles. 
#
#++

module Makefile
  
  class Rule
    
    require 'set'
    
    def initialize(target = nil)
      @target = target
      @prereqs = Set.new
      @cmds = Set.new
    end
    
    attr_accessor :prereqs, :cmds, :phony

    def to_s
      (@phony ? ".PHONY: #{@target}\n" : "") +
      "#{@target}: #{@prereqs.to_a.wrap}\n" +
      @cmds.map { |c| "\t#{c}\n" }.join + "\n"
    end
    
  end

end

class Array
  def wrap(max_width = 72, prefix = "\t\t", suffix = " \\\n")
    i = [(shift.dup rescue '')]
    self.inject(i) do |m, w|
      w = w.dup
      if m.last.length + w.length <= max_width
        m.last << ' ' << w
      else
        m << w
      end
      m
    end.join("#{suffix}#{prefix}")
  end
end