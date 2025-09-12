require 'mister_bin'

module Completely
  module Commands
    class Base < MisterBin::Command
      class << self
        def param_config_path
          param 'CONFIG_PATH', <<~USAGE
            Path to the YAML configuration file [default: completely.yaml].
            Can also be set by an environment variable.
          USAGE
        end

        def option_function
          option '-f --function NAME',
            'Modify the name of the function in the generated script.'
        end

        def environment_config_path
          environment 'COMPLETELY_CONFIG_PATH',
            'Path to a completely configuration file [default: completely.yaml].'
        end

        def environment_debug
          environment 'COMPLETELY_DEBUG', 'If not empty, the generated script will include ' \
            'an additional debugging snippet that outputs the compline and current word to ' \
            'a text file when a completion is requested.'
        end
      end

    protected

      def script
        @script ||= completions.script
      end

      def completions
        @completions ||= if config_path == '-'
          raise Error, 'Nothing is piped on stdin' if $stdin.tty?

          Completions.read $stdin, function_name: args['--function']
        else
          Completions.load config_path, function_name: args['--function']
        end
      end

      def config_path
        @config_path ||= args['CONFIG_PATH'] || ENV['COMPLETELY_CONFIG_PATH'] || 'completely.yaml'
      end

      def output_path
        @output_path ||= args['OUTPUT_PATH'] || ENV['COMPLETELY_OUTPUT_PATH'] || stdout || "#{config_basename}.bash"
      end

      def stdout
        @stdout ||= config_path == '-' ? '-' : nil
      end

      def config_basename
        File.basename config_path, File.extname(config_path)
      end

      def syntax_warning
        say! "\nr`WARNING:`\nr`Your configuration is invalid.`"
        say! 'r`All patterns must start with the same word.`'
      end
    end
  end
end
