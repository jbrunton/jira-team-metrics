require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config::Types do
  module Types
    include JiraTeamMetrics::Config::Types
  end

  describe Types::String do

    subject { Types::String.new }

    describe "#type_check" do
      it "returns true for Strings" do
        expect(subject.type_check("string")).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(nil)).to eq(false)
        expect(subject.type_check(123)).to eq(false)
      end
    end
  end

  describe Types::Boolean do
    subject { Types::Boolean.new }

    describe "#type_check" do
      it "returns true for Booleans" do
        expect(subject.type_check(true)).to eq(true)
        expect(subject.type_check(false)).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(nil)).to eq(false)
        expect(subject.type_check(123)).to eq(false)
      end
    end
  end

  describe Types::Integer do
    subject { Types::Integer.new }

    describe "#type_check" do
      it "returns true for Integers" do
        expect(subject.type_check(123)).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(nil)).to eq(false)
        expect(subject.type_check(true)).to eq(false)
      end
    end
  end

  describe Types::Optional do
    subject { Types::Optional.new(Types::String.new) }

    describe "#type_check" do
      it "returns true for nil values" do
        expect(subject.type_check(nil)).to eq(true)
      end

      it "returns true for values of the given type" do
        expect(subject.type_check("string")).to eq(true)
      end

      it "returns false for other types" do
        expect(subject.type_check(123)).to eq(false)
        expect(subject.type_check(true)).to eq(false)
      end
    end
  end

  describe Types::Array do
    subject { Types::Array.new(Types::String.new) }

    describe "#type_check" do
      it "returns true for empty arrays" do
        expect(subject.type_check([])).to eq(true)
      end

      it "returns true for arrays containing the given type" do
        expect(subject.type_check(["string"])).to eq(true)
      end

      it "returns false for arrays containing other types" do
        expect(subject.type_check(["string", 2])).to eq(false)
      end

      it "returns false for other types" do
        expect(subject.type_check(123)).to eq(false)
        expect(subject.type_check(true)).to eq(false)
      end
    end
  end

  describe Types::Hash do
    let(:schema) do
      {
        id: Types::Integer.new,
        name: Types::String.new
      }
    end

    subject { Types::Hash.new(schema) }

    describe "#type_check" do
      it "returns true for hashes matching the schema" do
        expect(subject.type_check({ id: 123, name: 'foo' })).to eq(true)
      end

      it "returns false for hashes not matching the schema" do
        expect(subject.type_check({ id: '123', name: 'foo' })).to eq(false)
        expect(subject.type_check({ id: 123 })).to eq(false)
      end

      it "returns false for other types" do
        expect(subject.type_check(123)).to eq(false)
        expect(subject.type_check(true)).to eq(false)
      end
    end
  end
end
