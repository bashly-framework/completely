require 'yaml'
require 'erb'

module Completely
  class Completions
    attr_reader :config

    class << self
      def load(path, function_name: nil)
        new Config.load(path), function_name: function_name
      end

      def read(io, function_name: nil)
        new Config.read(io), function_name: function_name
      end
    end

    def initialize(config, function_name: nil)
      @config = normalize_config config
      @function_name = function_name
    end

    def flat_config
      @flat_config ||= config.flat_config
    end

    def patterns
      @patterns ||= patterns!
    end

    def valid?
      return pattern_programs.uniq.one? if pattern_config?

      pattern_prefixes.uniq.one?
    end

    def script
      ERB.new(template, trim_mode: '%-').result(binding)
    end

    def wrapper_function(name = nil)
      name ||= 'send_completions'

      script_lines = script.split("\n").map do |line|
        clean_line = line.gsub("'") { "\\'" }
        "  echo $'#{clean_line}'"
      end.join("\n")

      "#{name}() {\n#{script_lines}\n}"
    end

    def tester
      @tester ||= Tester.new script: script, function_name: function_name
    end

  private

    def patterns!
      result = flat_config.map do |text, completions|
        Pattern.new text, completions, pattern_function_name
      end

      result.sort_by { |pattern| -pattern.length }
    end

    def template_path
      @template_path ||= begin
        template = pattern_config? ? 'pattern-config/template.erb' : 'flat-config/template.erb'
        File.expand_path("templates/#{template}", __dir__)
      end
    end

    def template
      @template ||= File.read(template_path)
    end

    def command
      @command ||= pattern_config? ? config.model[:program] : flat_config.keys.first.split.first
    end

    def function_name
      @function_name ||= "_#{command}_completions"
    end

    def pattern_function_name
      @pattern_function_name ||= "#{function_name}_filter"
    end

    def pattern_prefixes
      patterns.map(&:prefix)
    end

    def complete_options_line
      options = config.options[:complete_options]
      return nil if options.nil? || options.strip.empty?

      "#{options} "
    end

    def pattern_config?
      config.is_a? PatternConfig
    end

    def pattern_tree
      config.model[:tree]
    end

    def pattern_nodes
      @pattern_nodes ||= flatten_pattern_tree pattern_tree
    end

    def pattern_programs
      config.model[:programs]
    end

    def pattern_node_id(node)
      pattern_nodes.index { |entry| entry[:node].equal? node }
    end

    def pattern_node_options(node)
      node[:option_groups].flat_map do |name|
        config.model[:options][name] || []
      end
    end

    def pattern_node_depth(node)
      pattern_nodes.dig(pattern_node_id(node), :depth)
    end

    def pattern_child_transitions(node)
      node[:children].flat_map do |child|
        pattern_word_names(child[:word]).map do |name|
          { name: name, node: child }
        end
      end
    end

    def pattern_node_child_words(node)
      node[:children].flat_map { |child| pattern_word_names child[:word] }.uniq
    end

    def pattern_has_unique_options?
      pattern_nodes.any? do |entry|
        pattern_node_options(entry[:node]).any? { |option| !option[:repeatable] }
      end
    end

    def pattern_word_names(word)
      [word[:name], *word[:aliases]]
    end

    def flatten_pattern_tree(node, depth = 0)
      [
        { node: node, depth: depth },
        *node[:children].flat_map { |child| flatten_pattern_tree child, depth + 1 },
      ]
    end

    def pattern_source_empty?(source)
      source[:items].empty?
    end

    def pattern_source_compgen(source)
      wordlist = source[:items]
        .select { |item| item[:type] == :value }
        .map { |item| item[:value] }
        .join(' ')

      builtins = source[:items]
        .select { |item| item[:type] == :builtin }
        .map { |item| "-A #{bash_escape item[:value]}" }

      parts = []
      parts << %[-W "#{bash_double_quote_escape wordlist}"] unless wordlist.empty?
      parts.concat builtins
      parts.join(' ')
    end

    def bash_escape(value)
      value.to_s.gsub('\\', '\\\\\\').gsub('"', '\\"')
    end

    def bash_double_quote_escape(value)
      value.to_s.gsub('\\', '\\\\\\').gsub('"', '\\"')
    end

    def normalize_config(config)
      case config
      when FlatConfig, PatternConfig
        config
      else
        Config.build config
      end
    end
  end
end
