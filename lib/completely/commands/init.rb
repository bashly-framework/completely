require 'completely/commands/base'

module Completely
  module Commands
    class Init < Base
      help 'Create a new sample Completely YAML configuration file'

      usage 'completely init [--format FORMAT] [CONFIG_PATH]'
      usage 'completely init (-h|--help)'

      option '-f --format FORMAT', 'Sample format: pattern, flat, or nested [default: pattern]'

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
          raise Error, "Invalid format: #{format}" unless sample_filenames.key? format

          File.expand_path "../templates/#{sample_filename}", __dir__
        end
      end

      def sample_filename
        sample_filenames.fetch format
      end

      def sample_filenames
        @sample_filenames ||= {
          'flat'    => 'flat-config/sample.yaml',
          'nested'  => 'flat-config/sample-nested.yaml',
          'pattern' => 'pattern-config/sample.yaml',
        }
      end
    end
  end
end
