module Completely
  class Pattern
    attr_reader :text, :completions, :function_name

    def initialize(text, completions, function_name)
      @text = text
      @completions = completions || []
      @function_name = function_name
    end

    def length
      @length ||= text.size
    end

    def empty?
      completions.empty?
    end

    def words
      @words ||= completions.grep_v(/^<.*>$/)
    end

    def actions
      @actions ||= completions.filter_map do |word|
        action = word[/^<(.+)>$/, 1]
        "-A #{action}" if action
      end
    end

    def prefix
      text.split(/ |\*/).first
    end

    def case_string
      if text_without_prefix.empty?
        '*'
      elsif text_without_prefix.include? '*'
        text_without_prefix.gsub(/([^*]+)/, "'\\1'")
      else
        "'#{text_without_prefix}'*"
      end
    end

    def text_without_prefix
      @text_without_prefix ||= text[/^#{prefix}\s*(.*)/, 1]
    end

    def compgen
      @compgen ||= compgen!
    end

  private

    def compgen!
      result = []
      result << actions.join(' ').to_s if actions.any?
      result << %[-W "$(#{function_name} #{quoted_words.join ' '})"] if words.any?
      result.any? ? result.join(' ') : nil
    end

    def quoted_words
      @quoted_words ||= words.map { |word| %("#{escape_for_double_quotes word}") }
    end

    def escape_for_double_quotes(word)
      word.gsub(/["\\]/, '\\\\\&')
    end
  end
end
