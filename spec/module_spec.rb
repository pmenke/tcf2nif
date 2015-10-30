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

require 'spec_helper'

describe Tcf2Nif::Transformer do

  context 'modularized export' do

    it 'Phantom exports', mod: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'phantom.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:modularized)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'modularized', 'phantom.n3'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
      #puts "TTL"
      #prefixes = Tcf2Nif::STANDARD_PREFIXES
      #RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'modularized', 'phantom.ttl'), :format => :turtle,
      #      base_uri: 'http://example.org/tcf2nif/', prefixes: prefixes) do |writer|
      #  writer << RDF::Repository.new do |repo|
      #    repo << graph
      #  end
      #end
    end
  end

end
