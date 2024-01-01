require "minitest/autorun"

describe "foobar" do
  let(:my_number) { 4 + 4 }
  it "does something useful" do
    value( my_number ).must_equal 8
  end
end
