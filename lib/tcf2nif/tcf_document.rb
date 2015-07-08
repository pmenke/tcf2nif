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
      @tokens = Array.new
      @id_map = Hash.new
      @token_map = Hash.new

      process_tokens
      unless @tokens.all?{|t| t.boundaries? }
        calculate_character_offsets
      end

      # TODO process pos and lemma information
      process_pos
      process_lemma

    end

    def token_map
      @token_map
    end

    def id_map
      @id_map
    end

    def calculate_character_offsets
      char_index = 0
      tokens.each do |token|
        new_index = text.index(token.form, char_index)
        new_offset = new_index + token.form.length
        token.boundaries= [new_index, new_offset]
        char_index = new_offset
      end
    end

    def text
      #puts "texts:      %i" % @doc.xpath('.//tc:text/text()', 'wl' => 'http://www.dspin.de/data', 'tc' => 'http://www.dspin.de/data/textcorpus').size
      #puts "text type:  %s" % @doc.xpath('.//tc:text/text()', 'wl' => 'http://www.dspin.de/data', 'tc' => 'http://www.dspin.de/data/textcorpus').class.name
      #puts "first type: %s" % @doc.xpath('.//tc:text/text()', 'wl' => 'http://www.dspin.de/data', 'tc' => 'http://www.dspin.de/data/textcorpus').first.class.name
      #puts "first cont: %s" % @doc.xpath('.//tc:text/text()', 'wl' => 'http://www.dspin.de/data', 'tc' => 'http://www.dspin.de/data/textcorpus').first.to_s.slice(0,128)

      @text ||= @doc.xpath('.//tc:text/text()', 'wl' => 'http://www.dspin.de/data', 'tc' => 'http://www.dspin.de/data/textcorpus').first.to_s
    end

    def tokens
      @tokens
    end

    def xml_sentences
      # /wl:D-Spin/tc:TextCorpus[1]/tc:text[1]
      @xml_sentences ||= @doc.xpath('//tc:sentences/tc:sentence', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end
    
    def xml_tokens
      @xml_tokens ||= @doc.xpath('//tc:tokens/tc:token', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end

    # TODO add deep support for sentences and related tokens

    def new_token(doc, xml_token)
      token_object = Tcf2Nif::Token.new(doc, xml_token)
      if xml_token.has_attribute?('start') && xml_token.has_attribute?('end')
        token_object.boundaries= [xml_token['start'].to_i, xml_token['end'].to_i]
      end
      token_object
    end

    def store_token(token_object, xml_token)
      @tokens << token_object
      @id_map[xml_token['ID']] = token_object
      @token_map[token_object] = xml_token['ID']
    end

    def token_for_id(xml_id)
      @id_map[xml_id]
    end

    def id_for_token(token)
      @token_map[token]
    end


    private

    def process_tokens
      xml_tokens.each do |xml_token|
        token = new_token(@doc, xml_token)
        store_token(token, xml_token)
      end
    end

    def process_pos
      xml_tags = @doc.xpath('//tc:POStags/tc:tag', 'tc' => 'http://www.dspin.de/data/textcorpus')
      xml_tags.each do |tag|
        val = tag.text
        ref = tag['tokenIDs']
        ref_obj = @id_map[ref]
        if val && ref_obj
          ref_obj.pos = val
        end
      end
    end

    def process_lemma
      xml_lemmas = @doc.xpath('//tc:lemmas/tc:lemma', 'tc' => 'http://www.dspin.de/data/textcorpus')
      xml_lemmas.each do |lemma|
        val = lemma.text
        ref = lemma['tokenIDs']
        ref_obj = @id_map[ref]
        if val && ref_obj
          ref_obj.lemma = val
        end
      end
    end
    
  end
  
end