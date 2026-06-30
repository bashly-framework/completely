module Completely
  class PatternConfig
    attr_reader :config, :options

    def initialize(config)
      @options = config.delete('completely_options')&.transform_keys(&:to_sym) || {}
      @config = config
    end

    def model
      validate!

      @model ||= {
        program: program,
        routes:  routes,
        options: parsed_options,
        tokens:  tokens,
      }
    end

    def flat_config
      raise Error, 'Pattern config cannot be converted to flat config'
    end

  private

    def patterns
      @patterns ||= Array config['patterns']
    end

    def option_groups
      @option_groups ||= config['options'] || {}
    end

    def token_sources
      @token_sources ||= config['tokens'] || {}
    end

    def program
      routes.first.dig(:words, 0, :name)
    end

    def routes
      @routes ||= patterns.map { |pattern| parse_pattern pattern }
    end

    def parsed_options
      @parsed_options ||= option_groups.to_h do |name, entries|
        [name, Array(entries).map { |entry| parse_option entry }]
      end
    end

    def tokens
      @tokens ||= token_sources.to_h do |name, source|
        [name, parse_source(name, source)]
      end
    end

    def validate!
      missing_options = referenced_options - option_groups.keys
      missing_tokens = referenced_tokens - token_sources.keys

      errors = []
      errors << "Unknown option group: #{missing_options.join ', '}" if missing_options.any?
      errors << "Unknown token: #{missing_tokens.join ', '}" if missing_tokens.any?
      raise ParseError, errors.join("\n") if errors.any?
    end

    def referenced_options
      patterns.flat_map do |pattern|
        pattern_parts(pattern).filter_map { |part| option_group_name(part) if option_group?(part) }
      end.uniq
    end

    def referenced_tokens
      pattern_tokens + option_tokens
    end

    def pattern_tokens
      patterns.flat_map do |pattern|
        pattern_parts(pattern).filter_map { |part| token_name(part) if token?(part) }
      end
    end

    def option_tokens
      option_groups.values.flatten.filter_map do |entry|
        _flag_part, value_part = option_parts entry
        token_name(value_part) if value_part
      end
    end

    def parse_pattern(pattern)
      result = { words: [], option_groups: [], positionals: [] }

      pattern_parts(pattern).each do |part|
        if option_group?(part)
          result[:option_groups] << option_group_name(part)
        elsif token?(part)
          result[:positionals] << parse_token(part)
        else
          result[:words] << parse_word(part)
        end
      end

      result
    end

    def parse_word(part)
      names = part.split('|')
      { name: names.first, aliases: names[1..] || [] }
    end

    def pattern_parts(pattern)
      pattern.scan(/\[[^\]]+\]|<[^>]+>|\S+/)
    end

    def parse_option(entry)
      flag_part, value_part = option_parts entry
      names = flag_part.split('|')

      result = { names: names }
      result[:value] = parse_token(value_part) if value_part
      result
    end

    def option_parts(entry)
      entry.scan(/<[^>]+>|\S+/)
    end

    def parse_token(part)
      name = token_name part
      { name: name, source: parse_source(name, token_sources[name]) }
    end

    def parse_source(_name, source)
      case source
      when Array
        { type: :values, value: source }
      when /^\$\(.*\)$/
        { type: :command, value: source }
      when String
        { type: :builtin, value: source }
      end
    end

    def option_group?(part)
      part.start_with?('[') && part.end_with?(']')
    end

    def option_group_name(part)
      part[1..-2].sub(/\s+options\z/, '')
    end

    def token?(part)
      part.start_with?('<') && part.end_with?('>')
    end

    def token_name(part)
      part[/\A<(.+)>\z/, 1]
    end
  end
end
