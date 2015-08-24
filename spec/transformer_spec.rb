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
  it 'should be a class' do
    expect(Tcf2Nif::Transformer).not_to be nil
    expect(Tcf2Nif::Transformer).to be_a Class
  end

  context 'without provenance information' do

    it 'Phantom of the Opera converts', phanno: true, noprov: true, sample: true, phantom: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'phantom.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:noprov)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'phantom.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
      # prefixes = Tcf2Nif::STANDARD_PREFIXES
      # RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'phantom.ttl'), format: :ttl, base_uri: 'http://example.org/tcf2nif/', prefixes: prefixes) do |writer|
      #   writer << RDF::Repository.new do |repo|
      #     repo << graph
      #   end
      # end
    end

    it 'Turn of the Screw converts', screwno: true, noprov: true, sample: true, screw: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'screw.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:noprov)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'screw.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
    end
    

    it 'Les Misérables converts', misno: true, noprov: true, sample: true, miserables: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'miserables.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:noprov)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'miserables.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
    end
    
  end

  context 'with plain provenance information' do

    it 'Phantom of the Opera converts', phanplain: true, plainprov: true, sample: true, phantom: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'phantom.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:plain)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'plainprov', 'phantom.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
    end

    it 'Turn of the Screw converts', screwplain: true, plainprov: true, sample: true, screw: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'screw.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:plain)#
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'plainprov', 'screw.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
    end


    it 'Les Misérables converts', misplain: true, plainprov: true, sample: true, miserables: true do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'miserables.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
      graph = @trans.transform(:plain)
      puts graph.size
      RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', 'plainprov', 'miserables.nt'), :format => :ntriples) do |writer|
        writer << RDF::Repository.new do |repo|
          repo << graph
        end
      end
    end

  end

  
  context 'with a valid TCF document' do
    
    before :each do 
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'phantom.xml'), 'r')
      #@xml_doc = Nokogiri::XML(@testfile)
      @tcf_doc = Tcf2Nif::TcfDocument.new(@testfile)
      @trans = Tcf2Nif::Transformer.new(@tcf_doc, {})
    end

    it 'checks RDF' do
      #puts RDF::Vocabulary.class.name
      #puts RDF::Vocabulary.instance_methods
    end
    context '::transform' do

      it 'can be run' do
        expect{@trans.transform}.not_to raise_error
      end

      it 'returns the correct object' do
        expect(@trans.transform).to be_a RDF::Graph
      end

      # it 'shows the RDF', slow: true do
      #   puts @tcf_doc.text.size
      #   graph = @trans.transform
      #   puts " transformation done"
      #   puts graph.size
      #   # prefixes = {
      #   #     nif: Tcf2Nif::NIF,
      #   #     rdfs: RDF::RDFS,
      #   #     xsd: RDF::XSD,
      #   #     penn: Tcf2Nif::PENN
      #   # }
      #   # File.open(File.join(Tcf2Nif::root, 'spec', 'out', 'tcftest.nt'), 'w') do |f|
      #   #   f << graph.dump(:ntriples) #, base_uri: 'http://example.org/tcf2nif/', prefixes: prefixes)
      #   # end
      #   puts " export done"
      # end
    end

  end

end