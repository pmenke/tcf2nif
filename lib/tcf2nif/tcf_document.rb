# encoding: utf-8
# This file is part of the tcf2nif gem.
# Copyright (c) 2015 Peter Menke, SFB 673, Universität Bielefeld
# http://www.sfb673.org
#
# tcf2nif is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# tcf2nif is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with tcf2nif. If not, see
# <http://www.gnu.org/licenses/>.

module Tcf2Nif
  
  class TcfDocument
    
    def initialize(io)
      @doc = Nokogiri::XML(io)
      # TODO add a method that reads the XML into Ruby structures
      # first: determine offsets
      #
    end

    def text
      @text ||= @doc.xpath('//tc:text', 'tc' => 'http://www.dspin.de/data/textcorpus').text
    end

    def tokens
      @tokens ||= process_tokens
    end

    def xml_sentences
      @xml_sentences ||= @doc.xpath('//tc:sentences/tc:sentence', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end
    
    def xml_tokens
      @xml_tokens ||= @doc.xpath('//tc:tokens/tc:token', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end

    private

    def process_tokens
      result = Array.new
      xml_tokens.each do |xml_token|
        result << Tcf2Nif::Token.new(@doc, xml_token)
      end
      result
    end
    
  end
  
end