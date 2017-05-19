require 'draper'

class IssuesDecorator < Draper::CollectionDecorator
  def cycle_times
    object.map{ |i| i.cycle_time }
  end
end