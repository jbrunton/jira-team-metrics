require 'rails_helper'

RSpec.describe JiraTeamMetrics::Config::Types do
  module Types
    include JiraTeamMetrics::Config::Types
  end

  describe Types::String do

    subject { Types::String.new }

    describe "#describe_type" do
      it "describes a String" do
        expect(subject.describe_type).to eq("String")
      end
    end

    describe "#parse" do
      it "parses values" do
        expect(subject.parse("string")).to eq("string")
      end
    end

    describe "#type_check!" do
      it "passes for Strings" do
        subject.type_check!("string")
      end

      it "fails for other types" do
        expect { subject.type_check!(nil) }.to raise_error(TypeError, "Expected String but found NilClass")
        expect { subject.type_check!(123) }.to raise_error(TypeError, "Expected String but found Integer")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?("string")).to eq(false)
      end
    end
  end

  describe Types::Boolean do
    subject { Types::Boolean.new }

    describe "#describe_type" do
      it "describes a Boolean" do
        expect(subject.describe_type).to eq("Boolean")
      end
    end

    describe "#parse" do
      it "parses values" do
        expect(subject.parse(true)).to eq(true)
      end
    end

    describe "#type_check!" do
      it "passes for Booleans" do
        subject.type_check!(true)
        subject.type_check!(false)
      end

      it "fails for other types" do
        expect { subject.type_check!(nil) }.to raise_error(TypeError, "Expected Boolean but found NilClass")
        expect { subject.type_check!(123) }.to raise_error(TypeError, "Expected Boolean but found Integer")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?(false)).to eq(false)
      end
    end
  end

  describe Types::Integer do
    subject { Types::Integer.new }

    describe "#describe_type" do
      it "describes an Integer" do
        expect(subject.describe_type).to eq("Integer")
      end
    end

    describe "#parse" do
      it "parses values" do
        expect(subject.parse(123)).to eq(123)
      end
    end

    describe "#type_check!" do
      it "passes for Integers" do
        subject.type_check!(123)
      end

      it "fails for other types" do
        expect { subject.type_check!(nil) }.to raise_error(TypeError, "Expected Integer but found NilClass")
        expect { subject.type_check!(true) }.to raise_error(TypeError, "Expected Integer but found TrueClass")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?(123)).to eq(false)
      end
    end
  end

  describe Types::Optional do
    subject { Types::Optional.new(Types::Hash.new(id: Types::Integer.new, name: Types::String.new)) }

    describe "#describe_type" do
      it "describes the Optional type" do
        expect(subject.describe_type).to eq("Optional<Hash[id: Integer, name: String]>")
      end
    end

    describe "#parse" do
      it "recursively parses values" do
        value = subject.parse({ id: 123, name: 'foo' })
        expect(value.id).to eq(123)
        expect(value.name).to eq('foo')
      end
    end

    describe "#type_check!" do
      it "passes for nil values" do
        subject.type_check!(nil)
      end

      it "passes for values of the given type" do
        subject.type_check!({ id: 123, name: 'foo' })
      end

      it "passes for optional hashes with nil values" do
        subject.type_check!({ id: nil, name: nil })
      end

      it "fails for optional hashes with invalid values" do
        expect { subject.type_check!({ id: 123, name: nil }) }.to raise_error(TypeError, "Invalid type for field 'name': expected String but was NilClass")
      end

      it "fails for other types" do
        expect { subject.type_check!(123) }.to raise_error(TypeError, "Expected Hash but found Integer")
        expect { subject.type_check!(true) }.to raise_error(TypeError, "Expected Hash but found TrueClass")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns true if the value is like nil for the given schema" do
        expect(subject.is_like_nil?(nil)).to eq(true)
        expect(subject.is_like_nil?({ id: nil, name: nil })).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?({ id: 123, name: nil })).to eq(false)
      end
    end
  end

  describe Types::Array do
    subject { Types::Array.new(Types::String.new) }

    describe "#describe_type" do
      it "describes the Array type" do
        expect(subject.describe_type).to eq("Array<String>")
      end
    end

    describe "#parse" do
      it "recursively parses values" do
        type = Types::Array.new(Types::Hash.new(name: Types::String.new))
        arr = type.parse([{name: 'foo'}])
        expect(arr[0].name).to eq('foo')
      end
    end

    describe "#type_check!" do
      it "passes for empty arrays" do
        subject.type_check!([])
      end

      it "passes for arrays containing the given type" do
        subject.type_check!(["string"])
      end

      it "fails for arrays containing other types" do
        expect { subject.type_check!([123]) }.to raise_error(TypeError, "Expected String but found Integer")
      end

      it "fails for non-array types" do
        expect { subject.type_check!(123) }.to raise_error(TypeError, "Expected Array but found Integer")
        expect { subject.type_check!(true) }.to raise_error(TypeError, "Expected Array but found TrueClass")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns true if empty" do
        expect(subject.is_like_nil?([])).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?(["string"])).to eq(false)
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

    describe "#describe_type" do
      it "describes the Hash type" do
        expect(subject.describe_type).to eq("Hash[id: Integer, name: String]")
      end
    end

    describe "parse" do
      it "returns the hash as an OpenStruct" do
        struct = subject.parse(id: 123, name: 'foo')
        expect(struct.id).to eq(123)
        expect(struct.name).to eq('foo')
      end
    end

    describe "#type_check!" do
      it "passes for hashes matching the schema" do
        subject.type_check!({ id: 123, name: 'foo' })
      end

      it "fails for hashes not matching the schema" do
        expect { subject.type_check!({ id: '123', name: 'foo' }) }.to raise_error(TypeError, "Invalid type for field 'id': expected Integer but was String")
      end

      it "fails for missing required fields" do
        expect { subject.type_check!({ id: 123 }) }.to raise_error(TypeError, "Invalid type for field 'name': expected String but was NilClass")
      end

      it "fails for unexpected fields" do
        expect { subject.type_check!({ id: 123, name: 'foo', bar: 'baz' }) }.to raise_error(TypeError, "Unexpected field 'bar' found in hash")
      end

      it "fails for other types" do
        expect { subject.type_check!(123) }.to raise_error(TypeError, "Expected Hash but found Integer")
        expect { subject.type_check!(true) }.to raise_error(TypeError, "Expected Hash but found TrueClass")
      end
    end

    describe "#is_like_nil?" do
      it "returns true if nil" do
        expect(subject.is_like_nil?(nil)).to eq(true)
      end

      it "returns true if the values are all like nil" do
        expect(subject.is_like_nil?({ id: nil, name: nil })).to eq(true)
      end

      it "returns false otherwise" do
        expect(subject.is_like_nil?({ id: 123 })).to eq(false)
      end
    end
  end
end
