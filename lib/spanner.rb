class Spanner

  ParseError = Class.new(RuntimeError)

  def self.parse(str, opts = nil)
    Spanner.new(str, opts).parse
  end
  
  attr_reader :value, :raise_on_error, :from
  
  def initialize(value, opts)
    @value = value
    @on_error = opts && opts.key?(:on_error) ? opts[:on_error] : :raise
    
    
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
  
  def error(err)
    if on_error == :raise
      raise ParseError.new(err)
    end
  end
  
  def parse
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
        when 's', 'sec', 'seconds'  then 1
        when 'h', 'hours', 'hrs'    then 3600
        when 'm', 'min', 'minutes'  then 60
        when 'd', 'days'            then 86_400
        when 'w', 'wks', 'weeks'    then 604_800
        when 'months', 'month', 'm' then 2_629_743.83
        when 'years', 'y'           then 31_556_926
        when /\As/                  then 1
        when /\Am/                  then 60
        when /\Ah/                  then 86_400
        when /\Aw/                  then 604_800
        when /\Am/                  then 2_629_743.83
        when /\Ay/                  then 31_556_926
        end
        
        part_contextualized = part
        parts << (parts.pop * multiplier)
      end
    end
    
    if parts.empty?
      nil
    else
      value = parts.inject(from) {|s, p| s += p}
      value.ceil == value ? value.ceil : value
    end
  end
  
end