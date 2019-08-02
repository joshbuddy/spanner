require "test_helper"

describe Spanner do
  it "should return nil for empty strings" do
    assert_nil Spanner.parse('')
  end

  it "should assume seconds" do
    assert_equal 1, Spanner.parse('1')
  end

  #simple
  { '.5s' => 0.5, '1s' => 1, '1.5s' => 1.5, '1m' => 60, '1.5m' => 90, '1hr' => 3600, '1d' => 86400, '1.7233312d' => 148895.81568, '1M' => Spanner.days_in_month(Time.new.year, Time.new.month) * 24 * 60 * 60 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      assert_equal output, Spanner.parse(input)
    end
  end

  #complex
  { '1m23s' => 83 }.each do |input, output|
    it "should parse #{input} and return #{output}" do
      assert_equal output, Spanner.parse(input)
    end
  end

  it "should let you set the length of a month" do
    assert_equal 4936, Spanner.parse("4 months", :length_of_month => 1234)
  end

  it "should accept time as from option" do
    now = Time.new
    assert_equal now.to_i + 23, Spanner.parse('23s', :from => now)
  end

  it "should accept special :now as from option" do
    assert_equal Time.new.to_i + 23, Spanner.parse('23s', :from => :now)
  end
end
