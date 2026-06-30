module Completely
  class Config
    class << self
      def parse(str)
        build YAML.load(str, aliases: true)
      rescue Psych::Exception => e
        raise ParseError, "Invalid YAML: #{e.message}"
      end

      def load(path) = parse(File.read(path))
      def read(io) = parse(io.read)

      def build(config)
        if pattern_config? config
          PatternConfig.new config
        else
          FlatConfig.new config
        end
      end

      def pattern_config?(config)
        config.is_a?(Hash) && config.has_key?('patterns')
      end
    end
  end
end
