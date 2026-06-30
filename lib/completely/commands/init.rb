require 'completely/commands/base'

module Completely
  module Commands
    class Init < Base
      help 'Create a new sample YAML configuration file'

      usage 'completely init [--nested] [CONFIG_PATH]'
      usage 'completely init (-h|--help)'

      option '-n --nested', 'Generate a nested configuration'

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

      def nested?
        args['--nested']
      end

      def sample_path
        @sample_path ||= begin
          sample_name = nested? ? 'sample-nested' : 'sample'
          File.expand_path "../templates/flat-config/#{sample_name}.yaml", __dir__
        end
      end
    end
  end
end
