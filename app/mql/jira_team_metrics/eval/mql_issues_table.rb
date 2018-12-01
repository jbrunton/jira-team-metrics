# class JiraTeamMetrics::Eval::MqlIssuesTable < JiraTeamMetrics::Eval::MqlTable
#   def initialize(issues)
#     super(['key', 'summary', 'issuetype'], issues)
#   end
#
#   def to_data_table
#     JiraTeamMetrics::DataTable.new(
#       @columns,
#       @rows.map do |issue|
#         @columns.map do |col_name|
#           binding.pry
#           JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(col_name)
#         end
#       end
#     )
#   end
#
#   def select_field(col_name, row_index)
#     JiraTeamMetrics::IssueFieldResolver.new(rows[row_index]).resolve(col_name)
#   end
#
#   def select_rows
#     selected_rows = []
#     @rows.each_with_index do |row, row_index|
#       selected_rows << row if yield(row_index)
#     end
#     JiraTeamMetrics::Eval::MqlIssuesTable.new(selected_rows)
#   end
#
#   def map_rows
#     mapped_rows = []
#     @rows.each_with_index do |_, row_index|
#       mapped_rows << yield(row_index)
#     end
#     JiraTeamMetrics::Eval::MqlIssuesTable.new(mapped_rows)
#   end
#
#   def sort_rows(order)
#     sorted_rows = @rows.each_with_index.sort_by do |_, row_index|
#       yield(row_index)
#     end.map{ |row, _| row }
#     JiraTeamMetrics::Eval::MqlIssuesTable.new(
#       order == 'desc' ? sorted_rows.reverse : sorted_rows)
#   end
#
#   def group_by(expr_name)
#     grouped_results = @rows.each_with_index.group_by do |_, row_index|
#       group_key = yield(row_index)
#       group_key
#     end.map{ |key, rows| [key, rows.map{ |row, _| row }] }
#     JiraTeamMetrics::Eval::MqlTable.new(
#       [expr_name],
#       grouped_results)
#   end
# end
