require 'rails_helper'

RSpec.describe QueryBuilder do
  let(:some_query) { 'some query'}
  let(:builder) { QueryBuilder.new(some_query) }

  describe "#query" do
    it "returns the query" do
      expect(builder.query).to eq('some query')
    end
  end

  describe "#and" do
    let(:another_query) { 'another query'}

    it "returns the builder" do
      expect(builder.and(another_query)).to be(builder)
    end

    it "returns the conjunction of the queries" do
      expect(builder.and(another_query).query).to eq('(some query) AND (another query)')
    end

    it "strips the query of any order by clauses" do
      expect(builder.and("#{another_query} ORDER BY Rank ASC").query).to eq('(some query) AND (another query)')
    end
  end
end