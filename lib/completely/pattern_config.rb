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
      errors.concat repeatable_positional_errors
      raise ParseError, errors.join("\n") if errors.any?
    end

    def repeatable_positional_errors
      patterns.filter_map do |pattern|
        positionals = pattern_parts(pattern).select { |part| token? part }
        next unless positionals[0...-1].any? { |part| repeatable_token? part }

        "Repeatable positional must be the last positional in pattern: #{pattern}"
      end
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
        value_part = option_parts(entry).find { |part| token? part }
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
      pattern.scan(/\[[^\]]+\]|<[^>]+>\.\.\.|<[^>]+>|\S+/)
    end

    def parse_option(entry)
      flag_part, *parts = option_parts entry
      value_part = parts.find { |part| token? part }
      metadata_parts = parts.select { |part| metadata? part }
      unknown_parts = parts - [value_part] - metadata_parts
      raise ParseError, "Invalid option syntax: #{entry}" if unknown_parts.any?

      names = flag_part.split('|')

      result = { names: names, repeatable: false }
      result[:value] = parse_token(value_part) if value_part
      metadata_parts.each { |part| apply_option_metadata result, part }
      result
    end

    def option_parts(entry)
      entry.scan(/<[^>]+>|\([^)]+\)|\S+/)
    end

    def apply_option_metadata(result, part)
      case part
      when '(repeatable)'
        result[:repeatable] = true
      else
        raise ParseError, "Unknown option metadata: #{part}"
      end
    end

    def metadata?(part)
      part.start_with?('(') && part.end_with?(')')
    end

    def parse_token(part)
      repeatable = repeatable_token? part
      token_part = repeatable ? part.delete_suffix('...') : part
      name = token_name token_part
      result = { name: name, source: parse_source(name, token_sources[name]) }
      result[:repeatable] = true if repeatable
      result
    end

    def parse_source(_name, source)
      source_items = source.is_a?(Array) ? source : [source]
      items = source_items.compact.map { |item| parse_source_item item }
      { items: items }
    end

    def parse_source_item(item)
      return { type: :value, value: item.to_s[1..] } if item.to_s.start_with? '++'
      return { type: :builtin, value: item.to_s[1..] } if item.to_s.start_with? '+'

      { type: :value, value: item.to_s }
    end

    def option_group?(part)
      part.start_with?('[') && part.end_with?(']')
    end

    def option_group_name(part)
      part[1..-2].sub(/\s+options\z/, '')
    end

    def token?(part)
      part.match?(/\A<[^>]+>(?:\.\.\.)?\z/)
    end

    def repeatable_token?(part)
      part.end_with? '...'
    end

    def token_name(part)
      part.delete_suffix('...')[/\A<(.+)>\z/, 1]
    end
  end
end
