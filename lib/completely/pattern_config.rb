module Completely
  class PatternConfig
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def model
      @model ||= {
        program: program,
        routes: routes,
        options: options,
        tokens: tokens,
      }
    end

    def flat_config
      raise Error, 'Pattern config completion generation is not implemented yet'
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

    def options
      @options ||= option_groups.to_h do |name, entries|
        [name, Array(entries).map { |entry| parse_option entry }]
      end
    end

    def tokens
      @tokens ||= token_sources.to_h do |name, source|
        [name, parse_source(name, source)]
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
      flag_part, value_part = entry.split
      names = flag_part.split('|')

      result = { names: names }
      result[:value] = parse_token(value_part) if value_part
      result
    end

    def parse_token(part)
      name = part[/\A<(.+)>\z/, 1]
      { name: name, source: parse_source(name, token_sources[name]) }
    end

    def parse_source(name, source)
      case source
      when Array
        { type: :values, value: source }
      when /^\$\(.*\)$/
        { type: :command, value: source }
      when String
        { type: :builtin, value: source }
      else
        { type: :builtin, value: name }
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
  end
end
