require 'spec_helper'

describe Squid::Point do
  let(:options) { {minmax: minmax, height: height, labels: labels, stack: stack?, formats: formats} }
  let(:minmax) { [-50, 150] }
  let(:height) { 100 }
  let(:labels) { [false] }
  let(:stack?) { false }
  let(:formats) { [:percentage, :seconds] }
  let(:series) { [
    { 1 => -10.0, 2 => 109.9, 3 => 30.0 },
    { 1 => nil, 2 => 20.0, 3 => -50.0 },
  ] }

  describe '.for' do
    subject(:points) { Squid::Point.for series, **options }

    it 'calculates the height considering each value within minmax, relative to the height' do
      expect(points.first.map &:height).to eq [-5.0, 54.95, 15.0]
      expect(points.last.map &:height).to eq [nil, 10.0, -25.0]
    end

    it 'calculates the y considering the height and the y of the "0" value' do
      expect(points.first.map &:y).to eq [20.0, 79.95, 40.0]
      expect(points.last.map &:y).to eq [nil, 35.0, 0.0]
    end

    it 'returns the index of each value' do
      expect(points.first.map &:index).to eq [0, 1, 2]
      expect(points.last.map &:index).to eq [0, 1, 2]
    end

    it 'returns whether each value is negative' do
      expect(points.first.map &:negative).to eq [true, false, false]
      expect(points.last.map &:negative).to eq [false, false, true]
    end

    it 'does not returns the labels by default' do
      expect(points.first.map &:label).to eq [nil, nil, nil]
      expect(points.last.map &:label).to eq [nil, nil, nil]
    end

    context 'given the :labels option is set' do
      let(:labels) { [true, true] }

      it 'returns a formatted label for each value' do
        expect(points.first.map &:label).to eq %w(-10.0% 109.9% 30.0%)
        expect(points.last.map &:label).to eq ['', '0:20', '-0:50']
      end
    end

    context 'given the series are stacked' do
      let(:stack?) { true }

      it 'the height of each value is not affected' do
        expect(points.first.map &:height).to eq [-5.0, 54.95, 15.0]
        expect(points.last.map &:height).to eq [nil, 10.0, -25.0]
      end

      it 'the y of each value is affected by the previous value of the same index with the same signum' do
        expect(points.first.map &:y).to eq [20.0, 79.95, 40.0]
        expect(points.last.map &:y).to eq [nil, 89.95, 0.0]
      end
    end

    context "given a positive min" do
      let(:minmax) { [100, 150] }
      let(:series) { [
        { 1 => 110.0, 2 => 100, 3 => 130.0 },
        { 1 => nil, 2 => 120.0, 3 => 150.0 },
      ] }

      it 'generates y values relative to the minimum' do
        expect(points.first.map &:y).to eq [20.0, 0.0, 60.0]
        expect(points.last.map &:y).to eq [nil, 40.0, 100.0]
      end
    end
  end
end
