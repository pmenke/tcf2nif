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
  
  class Transformer

    def initialize(tcf_doc, rdf_opts)
      @tcf_doc = tcf_doc
      @rdf_opts = rdf_opts
    end


    def char_uri(base, from,to)
      RDF::URI("#{base}#char=#{from},#{to}")
    end

    def twopart_uri(base, suffix)
      RDF::URI("#{base}##{suffix}")
    end

    def transform(mode = :plain)
      return transform_plain  if mode == :plain
      return transform_noprov if mode == :noprov
    end

    def uri_base
      'http://example.org/tcf2nif/example.txt'
    end

    def text_converter_uri
      RDF::URI('http://hdl.handle.net/11858/00-1778-0000-0004-BA56-7')
    end

    def tokenizer_uri
      RDF::URI('http://hdl.handle.net/11858/00-1778-0000-0004-BA56-7')
    end

    def pos_tagger_uri
      RDF::URI('http://hdl.handle.net/11858/00-247C-0000-0007-3739-5')
    end


    def tokenization_activity_uri
      twopart_uri(uri_base, 'TokenizationActivity')
    end

    def pos_tagging_activity_uri
      twopart_uri(uri_base, 'PosTaggingActivity')
    end

    def ne_tagging_activity_uri
      twopart_uri(uri_base, 'NeTaggingActivity')
    end

    def geo_tagging_activity_uri
      twopart_uri(uri_base, 'GeoTaggingActivity')
    end

    def dep_parsing_activity_uri
      twopart_uri(uri_base, 'DependencyParsingActivity')
    end

    def transform_noprov(reify=false)
      graph = RDF::Graph.new

      # create a document URI for the document.
      context_uri = char_uri(uri_base, 0, '')

      # this generates a representation of the whole primary text
      graph << [ context_uri, RDF.type, NIF.String ]
      graph << [ context_uri, RDF.type, NIF.Context ]
      graph << [ context_uri, RDF.type, NIF.RFC5147String ]
      graph << [ context_uri, NIF.isString, RDF::Literal.new(@tcf_doc.text, lang: :en) ]
      graph << [ context_uri, NIF.beginIndex, RDF::Literal.new(0, datatype: RDF::XSD.nonNegativeInteger) ]
      graph << [ context_uri, NIF.endIndex,   RDF::Literal.new(@tcf_doc.text.length, datatype: RDF::XSD.nonNegativeInteger) ]

      # This generates a representation of the single tokens
      @tcf_doc.tokens.each_with_index do |token,i|
        token_uri = char_uri(uri_base, token.begin_index, token.end_index)
        graph << [ token_uri, NIF.referenceContext, context_uri ]
        graph << [ token_uri, RDF.type, NIF.String ]
        graph << [ token_uri, RDF.type, NIF.Word ]
        graph << [ token_uri, RDF.type, NIF.RFC5147String ]
        graph << [ token_uri, NIF.beginIndex, RDF::Literal.new(token.begin_index, datatype: RDF::XSD.nonNegativeInteger) ]
        graph << [ token_uri, NIF.endIndex, RDF::Literal.new(token.end_index, datatype: RDF::XSD.nonNegativeInteger) ]
        graph << [ token_uri, NIF.anchorOf, RDF::Literal.new(token.form, datatype: RDF::XSD.string) ]

        # adds data about POS if this data is present
        if token.pos? && token.pos =~ /\w+/
          # TODO Tokens must be checked whether they contain strange characters!
          nif_pos(token, i, reify).each do |trip|
            graph << trip
          end
        end
        # Adds data about lemma if this data is present
        if token.lemma?
          nif_lemma(token, i, reify).each do |trip|
            graph << trip #[ token_uri, NIF.lemma, RDF::Literal.new(token.lemma, datatype: RDF::XSD.string) ]
          end
        end
      end

      # TODO add information about named entities
      # named entities
      # get all named entities from the corpus.
      # are they in there, anyway?
      @tcf_doc.named_entities.each_with_index do |ne,i|
        # generate a string for reference if more than one token is used.
        # else, use just the URI for that given token.
        current_uri = char_uri(uri_base, ne.tokens.first.begin_index, ne.tokens.first.end_index)
        if ne.tokens.size > 1
          # create a new string thing
          min_ind = ne.tokens.min{|t| t.begin_index}.begin_index
          max_ind = ne.tokens.max{|t| t.end_index}.end_index
          current_uri = char_uri(uri_base, min_ind, max_ind)
        end
        anno_uri = twopart_uri(uri_base, "ne#{i}")
        graph << [current_uri, NIF::annotation, anno_uri]
        graph << [anno_uri, RDF.type, NIF.String]
        # puts '(%3i) %20s . %40s : %20s' % [ne.tokens.size, current_uri, ne.tokens.collect{|t| t.form}.join(' '), ne.category]
        graph << [anno_uri, NIF.taNerdCoreClassRef, NERD[ne.category.capitalize] ]
      end

      # TODO add information about geolocations
      @tcf_doc.geo_annotations.each_with_index do |geo,i|
        min_ind = geo.tokens.min{|t| t.begin_index}.begin_index
        max_ind = geo.tokens.max{|t| t.end_index}.end_index
        current_uri = char_uri(uri_base, min_ind, max_ind)
        graph << [current_uri, RDF.type, NIF.String]
        anno_uri = twopart_uri(uri_base, "geo#{i}")

        graph << [current_uri, NIF::annotation, anno_uri]
        graph << [anno_uri, Tcf2Nif::GEO.lat,  geo.lat]
        graph << [anno_uri, Tcf2Nif::GEO.long, geo.lon]
        graph << [anno_uri, Tcf2Nif::GEO.alt,  geo.alt]
        graph << [anno_uri, RDF::URI('http://example.org/tcf2nif/continent'), geo.continent]
      end

      # TODO add information about dependency trees

      @tcf_doc.dependency_map.each do |key, value|
        dep = key.first
        gov = key.last

        graph << [char_uri(uri_base, dep.begin_index, dep.end_index), NIF.dependency, char_uri(uri_base, gov.begin_index, gov.end_index)]
        graph << [char_uri(uri_base, dep.begin_index, dep.end_index), NIF.dependencyRelationType, RDF::Literal.new(value)]

      end
      # how to model these?

      graph

    end

    def transform_plain
      #puts "1"
      graph = transform_noprov(true)
      #puts "2"
      text_uri = char_uri(uri_base, 0, '')
      # add provenance info to some of the triples.
      # 1. add static Prov data for the tool chain.
      # 2. add provenance data for the TCF-formatted text.
      # 3. add provenance data for each token.
      #puts "3"
      @tcf_doc.tokens.each do |token|
        token_uri = char_uri(uri_base, token.begin_index, token.end_index)
        graph << [token_uri, Tcf2Nif::PROV.wasGeneratedBy, tokenization_activity_uri]
        graph << [token_uri, Tcf2Nif::PROV.wasDerivedFrom, text_uri]
        graph << [token_uri, Tcf2Nif::PROV.generatedAtTime, RDF::Literal.new('2015-07-09T14:00:00', type: RDF::XSD.dateTime)]
      end

      # add info to named entities
      #puts "4"
      @tcf_doc.named_entities.each_with_index do |ne,i|
        #puts " a"
        anno_uri = twopart_uri(uri_base, "ne#{i}")
        #puts " b"
        graph << [anno_uri, Tcf2Nif::PROV.wasGeneratedBy, ne_tagging_activity_uri]
        #puts " c"
        #puts ne.tokens.size
        ne.tokens.each do |tok|
          #puts tok.class.name
          #puts tok.begin_index
          #puts tok.end_index

          graph << [anno_uri, Tcf2Nif::PROV.wasDerivedFrom, char_uri(uri_base, tok.begin_index, tok.end_index)]
        #puts " d"
        end
        #puts " e"
        graph << [anno_uri, Tcf2Nif::PROV.generatedAtTime, RDF::Literal.new('2015-07-09T14:01:00', datatype: RDF::XSD.dateTime)]
      end
      #puts "5"

      @tcf_doc.geo_annotations.each_with_index do |geo,i|
        anno_uri = twopart_uri(uri_base, "geo#{i}")
        graph << [anno_uri, Tcf2Nif::PROV.wasGeneratedBy, geo_tagging_activity_uri]
        geo.tokens.each do |tok|
          graph << [anno_uri, Tcf2Nif::PROV.wasDerivedFrom, char_uri(uri_base, tok.begin_index, tok.end_index)]
        end
        graph << [anno_uri, Tcf2Nif::PROV.generatedAtTime, RDF::Literal.new('2015-07-09T14:02:00', datatype: RDF::XSD.dateTime)]
      end
      graph
    end

    def nif_pos(token, index, reify=false, tagset=Tcf2Nif::PENN)
      subject = char_uri(uri_base, token.begin_index, token.end_index)
      pos = token.pos
      if reify
        anno_uri = twopart_uri(uri_base, "Pos#{index}")
        [
          [subject, NIF.annotation, anno_uri],
          [anno_uri, NIF.oliaLink, tagset[pos]],
          [anno_uri, NIF.wasGeneratedBy, pos_tagging_activity_uri],
          [anno_uri, NIF.wasDerivedFrom, subject]
        ]
      else
        [[subject, NIF.oliaLink, tagset[pos]]]
      end
    end

    def nif_lemma(token, index, reify=false)
      subject = char_uri(uri_base, token.begin_index, token.end_index)
      lemma = token.lemma
      if reify
        anno_uri = twopart_uri(uri_base, "Lemma#{index}")
        [
          [subject, NIF.annotation, anno_uri],
          [anno_uri, NIF.lemma, RDF::Literal.new(lemma, datatype: RDF::XSD.string)],
          [anno_uri, NIF.wasGeneratedBy, pos_tagging_activity_uri],
          [anno_uri, NIF.wasDerivedFrom, subject]
        ]
      else
        [[subject, NIF.lemma, RDF::Literal.new(lemma, datatype: RDF::XSD.string)]]
      end
    end
    
  end
  
end