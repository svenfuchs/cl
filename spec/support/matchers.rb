RSpec::Matchers.define :suggest do |value|
  match do |block|
    error = raised_by(&block)
    error.suggestions.include?(value)
  end

  def raised_by
    yield
  rescue => e
    e
  end

  def supports_block_expectations?
    true
  end
end
