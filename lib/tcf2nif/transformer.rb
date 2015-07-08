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

    def transform(mode = :plain)
      return transform_plain if mode == :plain
    end

    def transform_plain
      graph = RDF::Graph.new

      # TODO obtain an URI basis from the opts.
      uri_base = 'http://example.org/tcf2nif/example.txt'

      # TODO create a document URI for the document.
      context_uri = char_uri(uri_base, 0, '')

      # TODO generate representation of the whole primary text
      graph << [ context_uri, RDF.type, NIF.String ]
      graph << [ context_uri, RDF.type, NIF.Context ]
      graph << [ context_uri, RDF.type, NIF.RFC5147String ]
      graph << [ context_uri, NIF.isString, RDF::Literal.new(@tcf_doc.text, lang: :en) ]
      graph << [ context_uri, NIF.beginIndex, RDF::Literal.new(0, datatype: RDF::XSD.nonNegativeInteger) ]
      graph << [ context_uri, NIF.endIndex,   RDF::Literal.new(@tcf_doc.text.length, datatype: RDF::XSD.nonNegativeInteger) ]

      # TODO generate representation of the single tokens
      @tcf_doc.tokens.each do |token|
        token_uri = char_uri(uri_base, token.begin_index, token.end_index)
        graph << [ token_uri, NIF.referenceContext, context_uri ]
        graph << [ token_uri, RDF.type, NIF.String ]
        graph << [ token_uri, RDF.type, NIF.Word ]
        graph << [ token_uri, RDF.type, NIF.RFC5147String ]
        graph << [ token_uri, NIF.beginIndex, RDF::Literal.new(token.begin_index, datatype: RDF::XSD.nonNegativeInteger) ]
        graph << [ token_uri, NIF.endIndex, RDF::Literal.new(token.end_index, datatype: RDF::XSD.nonNegativeInteger) ]
        graph << [ token_uri, NIF.anchorOf, RDF::Literal.new(token.form, datatype: RDF::XSD.string) ]
        if token.pos?
          graph << [ token_uri, NIF.oliaLink, Tcf2Nif::PENN[token.pos] ]
        end
        if token.lemma?
          graph << [ token_uri, NIF.lemma, RDF::Literal.new(token.lemma, datatype: RDF::XSD.string) ]
        end
      end
      graph
    end
    
  end
  
end