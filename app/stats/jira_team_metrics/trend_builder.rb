class JiraTeamMetrics::TrendBuilder
  def pluck(&pluck_block)
    @pluck_block = pluck_block
    self
  end

  def map(&map_block)
    @map_block = map_block
    self
  end

  def analyze(series)
    values = series.map{ |item| @pluck_block.call(item) }
    series.each_with_index.map do |item, index|
      sample = JiraTeamMetrics::TrendBuilder.pick_sample(values, index)
      @map_block.call(item, sample.mean, sample.standard_deviation)
    end
  end

  def self.sample_size(series_size)
    sample_size = (series_size * 0.2).to_i
    sample_size = sample_size + 1 if sample_size.even?
    [sample_size, 5].max
  end

  def self.pick_sample(values, index)
    sample_size = self.sample_size(values.length)
    start_index = [0, index - sample_size / 2 - 1].max
    end_index = start_index + sample_size

    while end_index > values.length
      start_index = start_index - 1 if start_index > 0
      end_index = end_index - 1
    end

    values[start_index..end_index - 1]
  end
end