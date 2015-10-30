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

describe 'PoS tagger comparison' do

  before :each do
    @file_a = File.open File.join(Tcf2Nif::root, 'spec/assets/pos_tagger_comparison/WebLichtPosComparison_SfS_StanfordParser.xml')
    @file_b = File.open File.join(Tcf2Nif::root, 'spec/assets/pos_tagger_comparison/WebLichtPosComparison_SfS_Jitar.xml')
    @tcf_a = Tcf2Nif::TcfDocument.new(@file_a)
    @tcf_b = Tcf2Nif::TcfDocument.new(@file_b)
  end

  it 'has the same number of tokens in both documents', poscomparison: true do
    puts @tcf_a.tokens.size
    expect(@tcf_a.tokens.size).to eq @tcf_b.tokens.size
  end

  it 'can list tokens alongside each other', poscomparison: true do
    @tcf_a.tokens.each_with_index do |token,i|
      pos1 = token.pos
      pos2 = @tcf_b.tokens[i].pos
      if pos1 != pos2
        puts "%6i %6i %20s  %8s %8s" % [token.begin_index, token.end_index , token.form, token.pos, @tcf_b.tokens[i].pos]
      end
    end
  end

  it 'converts both documents to NIF', poscomparison: true do
    names = %w(stanf jitar)
    [@tcf_a, @tcf_b].each_with_index do |tcf,i|
      @trans = Tcf2Nif::Transformer.new(tcf, {})
      graph = @trans.transform(:noprov)
      puts graph.size
      # RDF::Writer.open(File.join(Tcf2Nif::root, 'spec', 'out', "poscomp_#{names[i]}.n3"), :format => :ntriples) do |writer|
      #   writer << RDF::Repository.new do |repo|
      #   repo << graph
      #  end
      #end
    end
  end


end
