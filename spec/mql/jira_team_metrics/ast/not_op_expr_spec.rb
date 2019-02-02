require 'rails_helper'

RSpec.describe JiraTeamMetrics::AST::NotOpExpr do
  let(:value_expr) { JiraTeamMetrics::AST::ValueExpr.new(true) }
  let(:not_expr) { JiraTeamMetrics::AST::NotOpExpr.new(value_expr) }

  context "#eval" do
    it "when given a value expression, negates the value" do
      expr = JiraTeamMetrics::AST::NotOpExpr.new(value_expr)
      expect(expr.eval(nil)).to eq(false)
    end
  end

  context "#name" do
    it "returns the name without parentheses for value expressions" do
      expr = JiraTeamMetrics::AST::NotOpExpr.new(value_expr)
      expect(expr.expr_name).to eq("not true")
    end

    it "returns the name with parentheses for complex expressions" do
      expr = JiraTeamMetrics::AST::NotOpExpr.new(not_expr)
      expect(expr.expr_name).to eq("not (not true)")
    end
  end
end
