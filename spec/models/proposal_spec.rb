require 'spec_helper'

RSpec.describe Proposal, :type => :model do
  subject { described_class.new }

  it "is valid with valid attributes" do
    subject.body = "Anything"
    expect(subject).to be_valid
  end

  it "is not valid without a body" do
    expect(subject).to_not be_valid
  end
end
