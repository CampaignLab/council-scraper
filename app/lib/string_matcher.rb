class StringMatcher
  attr_reader :strings

  def initialize(strings: [])
    @strings = strings
    puts @strings.inspect
  end

  def match(input:, threshold: 5)
    standardized_input = standardize_name(input)
    mapped_strings = strings.map do |id, str|
      [id, str, levenshtein_distance(standardized_input, standardize_name(str))]
    end

    closest_match = mapped_strings.min_by { |_, _, dist| dist }
    return nil if closest_match.blank?

    distance = closest_match[2]

    if distance > threshold
      partial_match = strings.find do |_, str|
        str.include?(standardized_input) || standardized_input.include?(str)
      end
      return partial_match.nil? ? nil : { id: partial_match[0], string: partial_match[1] }
    end

    { id: closest_match[0], string: closest_match[1] }
  end

  private

  def levenshtein_distance(str1, str2)
    n = str1.length
    m = str2.length
    return m if n == 0
    return n if m == 0

    matrix = Array.new(n + 1) { Array.new(m + 1) }

    (0..n).each { |i| matrix[i][0] = i }
    (0..m).each { |j| matrix[0][j] = j }

    (1..n).each do |i|
      (1..m).each do |j|
        cost = str1[i - 1] == str2[j - 1] ? 0 : 1
        matrix[i][j] = [matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost].min
      end
    end

    matrix[n][m]
  end

  def standardize_name(name)
    name.gsub(/\b(Mr|Mrs|Miss|Ms|Councillors|Councillor|Cllr)\b/, '').strip
  end
end
