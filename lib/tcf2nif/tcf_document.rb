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
      @named_entities = Array.new
      @geo_annotations = Array.new
      @id_map = Hash.new
      @token_map = Hash.new
      @dependency_map = Hash.new()

      process_tokens
      unless @tokens.all?{|t| t.boundaries? }
        calculate_character_offsets
      end

      # TODO process pos and lemma information
      process_pos
      process_lemma

      process_named_entities
      process_geo_annotations
      process_dependencies

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

    def named_entities
      @named_entities
    end

    def geo_annotations
      @geo_annotations
    end

    def dependency_map
      @dependency_map
    end

    def store_named_entity(named_entity_object)
      @named_entities << named_entity_object
    end


    def xml_sentences
      # /wl:D-Spin/tc:TextCorpus[1]/tc:text[1]
      @xml_sentences ||= @doc.xpath('//tc:sentences/tc:sentence', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end
    
    def xml_tokens
      @xml_tokens ||= @doc.xpath('//tc:tokens/tc:token', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end

    def xml_named_entities
      @xml_named_entities ||= @doc.xpath('//tc:namedEntities/tc:entity', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end

    def xml_geo_annotations
      @xml_geo_annotations ||= @doc.xpath('//tc:geo/tc:gpoint', 'tc' => 'http://www.dspin.de/data/textcorpus')
    end

    def xml_dependencies
      @xml_dependencies ||= @doc.xpath('//tc:depparsing/tc:parse/tc:dependency', 'tc' => 'http://www.dspin.de/data/textcorpus')
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

    def process_named_entities
      xml_named_entities.each do |ent|
        nato = Tcf2Nif::NamedEntityAnnotation.new(@doc)
        nato.category = ent['class']
        token_refs = ent['tokenIDs'].split(/\s+/)
        tokens = token_refs.collect{|r| token_for_id(r)}
        tokens.each do |t|
          nato << t
        end
        @named_entities << nato
        #puts ent['class']
        #puts tokens.collect{|t| t.form}.join(' ')
      end
    end

    def process_geo_annotations
      xml_geo_annotations.each do |anno|
        geo = Tcf2Nif::GeoAnnotation.new(@doc)
        geo.lat = anno['lat'].to_f
        geo.lon = anno['lon'].to_f
        geo.alt = anno['alt'].to_f
        geo.continent = anno['continent']
        token_refs = anno['tokenIDs'].split(/\s+/)
        tokens = token_refs.collect{|r| token_for_id(r)}
        tokens.each do |t|
          geo << t
        end
        @geo_annotations << geo
      end
    end

    def process_dependencies
      xml_dependencies.each do |dep|
        # <tc:dependency depIDs="t_4" func="ROOT"/>
        # <tc:dependency govIDs="t_4" depIDs="t_2" func="aux"/>

        depToken = token_for_id(dep['depIDs'])

        if dep.has_attribute?('govIDs')
          # non-root tag. func is also defined.
          govToken = token_for_id(dep['govIDs'])
          @dependency_map[[depToken,govToken]] = dep['func']
        else
          # root tag.

        end

      end
    end
    
  end
  
end