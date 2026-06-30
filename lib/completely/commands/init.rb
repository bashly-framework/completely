require 'completely/commands/base'

module Completely
  module Commands
    class Init < Base
      help 'Create a new sample YAML configuration file'

      usage 'completely init [--format FORMAT] [CONFIG_PATH]'
      usage 'completely init (-h|--help)'

      option '-f --format FORMAT', 'Configuration format: pattern, flat, or nested [default: pattern]'

      param_config_path
      environment_config_path

      def run
        raise Error, "File already exists: #{config_path}" if File.exist? config_path

        File.write config_path, sample
        say "Saved m`#{config_path}`"
      end

    private

      def sample
        @sample ||= File.read sample_path
      end

      def format
        @format ||= args['--format'] || 'pattern'
      end

      def sample_path
        @sample_path ||= begin
          raise Error, "Invalid format: #{format}" unless %w[flat nested pattern].include? format

          File.expand_path "../templates/#{sample_filename}", __dir__
        end
      end

      def sample_filename
        {
          'flat'    => 'flat-config/sample.yaml',
          'nested'  => 'flat-config/sample-nested.yaml',
          'pattern' => 'pattern-config/sample.yaml',
        }[format]
      end
    end
  end
end
