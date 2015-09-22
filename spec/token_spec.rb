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

describe Tcf2Nif::Token do

  context 'inside a TCF document' do

    before :each do
      @testfile = File.open(File.join(Tcf2Nif::root, 'spec', 'assets', 'screw.xml'), 'r')
      @tcf = Tcf2Nif::TcfDocument.new(@testfile)
      @token = @tcf.tokens.first
    end

    it 'has the correct class' do
     expect(@token).to be_a Tcf2Nif::Token
    end

    it 'has access to a word form as a string' do
      expect(@token.form).to be_a String
    end

    context 'boundaries' do

      it 'has boundaries' do
        expect(@token).to respond_to(:begin_index)
        expect(@token).to respond_to(:end_index)
      end

      it 'has a numeric begin index' do
        expect(@token.begin_index).to be_a Numeric
        expect(@token.begin_index).to be >= 0
      end

      it 'has a numeric end index' do
        expect(@token.end_index).to be_a Numeric
        expect(@token.end_index).to be >= 0
      end

      it 'has reasonable values for both indices' do
        expect(@token.end_index).to be >= @token.begin_index
      end

      it 'has a positive length' do
        expect(@token).to respond_to(:length)
      end

    end

    context 'lemmata' do

      it 'knows whether it has been assigned a lemma or not' do
        expect(@token).to respond_to(:lemma?)
      end

    end

    context 'pos' do

      it 'knows whether it has been assigned a pos tag or not' do
        expect(@token).to respond_to(:pos?)
      end

    end

  end

end