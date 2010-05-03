require ~'spec_helper'

describe Spanner do
  
  it "should return nil for empty strings" do
    Spanner.parse('').should be_nil
  end

  it "should assume seconds" do
    Spanner.parse('1').should == 1
  end

  #simple
  { '.5s' => 0.5, '1s' => 1, '1.5s' => 1.5, '1m' => 60, '1.5m' => 90, '1d' => 86400, '1.7233312d' => 148895.81568, '1M' => Spanner.days_in_month(Time.new.year, Time.new.month) * 24 * 60 * 60 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      Spanner.parse(input).should == output
    end
  end

  #complex
  { '1m23s' => 83 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      Spanner.parse(input).should == output
    end
  end
  
  it "should let you set the length of a month" do
    Spanner.parse("4 months", :length_of_month => 1234).should == 4936
  end
  
  it "should accept time as from option" do
    now = Time.new
    Spanner.parse('23s', :from => now).should == now.to_i + 23
  end

  it "should accept special :now as from option" do
    Spanner.parse('23s', :from => :now).should == Time.new.to_i + 23
  end

end