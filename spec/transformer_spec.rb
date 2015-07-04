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

  context 'with a valid TCF document' do
    
    before :each do 
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'tcftest.xml'), 'r')
      @doc = Nokogiri::XML(@testfile)
    end
    
    it 'has access to the primary text' do
      expect(@doc).not_to be nil
      res = @doc.xpath('//tc:sentences/tc:sentence', 'tc' => 'http://www.dspin.de/data/textcorpus')
      puts res.size
      expect(res.size).to be > 0 
    end
    
  end

end