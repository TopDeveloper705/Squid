require 'squid/format'

module Squid
  class Point
    extend Format

    def self.for(series, minmax:, height:, labels:, stack:, formats:)
      @min = Hash.new 0
      @max = Hash.new 0
      min, max = minmax
      offset = -> (value) { value * height.to_f / (max-min) }
      y_offset = nil
      domain = []
      series.each do |data_h|
        data_h.each_key do |key|
          if key.is_a?(Numeric)
            if domain[0].nil? || key < domain[0]
              domain[0] = key
            end
            if domain[1].nil? || key > domain[1]
              domain[1] = key
            end
          else
            domain << key
          end
        end
      end
      if domain[1].is_a?(Numeric) && domain[0].is_a?(Numeric)
        x_offset_factor = (domain[1] - domain[0]).to_f
      end
      series.map.with_index do |data_hash, series_i|
        data_hash.map.with_index do |(x_value, y_value), i|
          if y_value
            h = y_for y_value, index: i, stack: false, &offset
            y = y_for y_value, index: i, stack: stack, &offset
            y_offset ||= offset.call(min || 0) # only calculate this once, since the result will never change
            y = y - y_offset
          end

          if x_value
            x = if x_value.is_a?(Numeric)
              ((x_value - domain[0]) / x_offset_factor) * (data_hash.size - 1)
            else
              domain.index(x_value)
            end
          end

          label = format_for y_value, formats[series_i] if labels[series_i]
          new y: y, x: x, height: h, index: i, label: label, negative: y_value.to_f < 0
        end
      end
    end

    attr_reader :y, :x, :height, :index, :label, :negative

    def initialize(y:, x:, height:, index:, label:, negative:)
      @y, @x, @height, @index, @label, @negative = y, x, height, index, label, negative
    end

  private

    def self.y_for(value, index:, stack:, &block)
      if stack
        hash = (value > 0) ? @max : @min
        yield(hash[index] += value)
      else
        yield(value)
      end
    end
  end
end
