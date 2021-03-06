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

describe Tcf2Nif::TcfDocument do
  it 'should be a class' do
    expect(Tcf2Nif::TcfDocument).not_to be nil
    expect(Tcf2Nif::TcfDocument).to be_a Class
  end

  context 'with a valid, loaded TCF document' do
    
    before :each do 
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'phantom.xml'), 'r')
      @tcf = Tcf2Nif::TcfDocument.new(@testfile)
    end
    
    it 'has access to the primary text' do
      puts @testfile
      puts @tcf
      expect(@tcf.text).not_to be nil
      expect(@tcf.text.size).to be > 0
    end

    it 'presents the primary text as a string' do
      expect(@tcf.text).to be_a String
    end
    
    it 'has access to raw XML tokens' do
      expect(@tcf.xml_tokens).not_to be nil
      expect(@tcf.xml_tokens.size).to be > 0
    end
    
    it 'has access to raw XML sentences' do
      expect(@tcf.xml_sentences).not_to be nil
      expect(@tcf.xml_sentences.size).to be > 0
    end

    it 'has access to raw XML named entities' do
      expect(@tcf.xml_named_entities).not_to be nil
      expect(@tcf.xml_named_entities.size).to be > 0
    end


    it 'obtains Ruby token representations from XML' do
      expect(@tcf.send(:process_tokens)).not_to be nil
    end

    it 'obtains Ruby named entity representations from XML', lily: true do
      expect(@tcf.named_entities).not_to be_empty

      @tcf.named_entities.each do |n|
        puts '%40s : %20s' % [n.tokens.collect{|t| t.form}.join(' '), n.category]
      end
    end

    context 'mapping between xml ids and token objects' do

      it 'has methods for querying the maps' do
        expect(@tcf).to respond_to(:token_for_id)
        expect(@tcf).to respond_to(:id_for_token)
      end

      it 'retrieves the correct token for an ID' do
        token = @tcf.token_for_id('t_0')
        expect(token).to eq @tcf.tokens.first
      end

      it 'retrieves the correct XML ID for a token' do
        id = @tcf.id_for_token(@tcf.tokens.first)
        expect(id).to eq 't_0'
      end

    end
  end

end