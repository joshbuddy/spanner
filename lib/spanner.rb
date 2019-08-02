require "spanner/version"
require "date"

class Spanner
  ParseError = Class.new(RuntimeError)

  def self.parse(str, opts = nil)
    Spanner.new(opts).parse(str)
  end

  attr_reader :value, :raise_on_error, :from

  def initialize(opts)
    @value = value
    @on_error = opts && opts.key?(:on_error) ? opts[:on_error] : :raise
    @length_of_month = opts && opts[:length_of_month]

    @from = if opts && opts.key?(:from)
              case opts[:from]
              when :now
                Time.new.to_i
              else
                opts[:from].to_i
              end
            else
              0
            end
  end

  def self.days_in_month(year, month)
    (Date.new(year, 12, 31) << (12 - month)).day
  end

  def length_of_month
    @length_of_month ||= Spanner.parse("#{Spanner.days_in_month(Time.new.year, Time.new.month)} days")
  end

  def error(err)
    if on_error == :raise
      raise ParseError.new(err)
    end
  end

  def parse(value)
    parts = []
    part_contextualized = nil
    value.scan(/[\+\-]?(?:\d*\.\d+|\d+)|[a-z]+/i).each do |part|
      part_as_float = Float(part) rescue nil
      if part_as_float
        parts << part_as_float
        part_contextualized = nil
      else
        if part_contextualized
          error "Part has already been contextualized with #{part_contextualized}"
          return nil
        end

        if parts.empty?
          parts << 1
        end

        # part is context
        multiplier = case part
                     when "s", "sec", "seconds" then 1
                     when "m", "min", "minutes" then 60
                     when "h", "hours", "hrs" then 3600
                     when "d", "days" then 86_400
                     when "w", "wks", "weeks" then 604_800
                     when "months", "month", "M" then length_of_month
                     when "years", "y" then 31_556_926
                     when /\As/ then 1
                     when /\Am/ then 60
                     when /\Ah/ then 3600
                     when /\Ad/ then 86_400
                     when /\Aw/ then 604_800
                     when /\AM/ then length_of_month
                     when /\Ay/ then 31_556_926
                     end

        part_contextualized = part
        parts << (parts.pop * multiplier)
      end
    end

    if parts.empty?
      nil
    else
      value = parts.inject(from) { |s, p| s += p }
      value.ceil == value ? value.ceil : value
    end
  end
end
