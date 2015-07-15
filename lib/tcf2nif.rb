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

require 'nokogiri'
require 'rdf'
require 'rdf/turtle'
require "tcf2nif/version"
require "tcf2nif/bounded_element"
require "tcf2nif/annotation"
require "tcf2nif/token"
require "tcf2nif/named_entity_annotation"
require "tcf2nif/geo_annotation"
require "tcf2nif/tcf_document"
require "tcf2nif/transformer"

module Tcf2Nif

  NIF  = RDF::Vocabulary.new("http://persistence.uni-leipzig.org/nlp2rdf/ontologies/nif-core#")
  PENN = RDF::Vocabulary.new("http://purl.org/olia/penn.owl#")
  NERD = RDF::Vocabulary.new("http://nerd.eurecom.fr/ontology#")
  GEO  = RDF::Vocabulary.new("http://www.w3.org/2003/01/geo/wgs84_pos#")
  PROV = RDF::Vocabulary.new("http://www.w3.org/ns/prov#")

  STANDARD_PREFIXES = {
          nif: Tcf2Nif::NIF,
          rdfs: RDF::RDFS,
          xsd: RDF::XSD,
          penn: Tcf2Nif::PENN,
          geo: Tcf2Nif::GEO,
          nerd: Tcf2Nif::NERD
      }

  def self.root
    File.expand_path('../..',__FILE__)
  end
    
end
