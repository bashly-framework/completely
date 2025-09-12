require 'completely/commands/base'

module Completely
  module Commands
    class Generate < Base
      help 'Generate the bash completion script to file or stdout'

      usage 'completely generate [CONFIG_PATH OUTPUT_PATH --function NAME --wrap NAME]'
      usage 'completely generate (-h|--help)'

      option_function
      option '-w --wrap NAME', 'Wrap the completion script inside a function that echos the ' \
        'script. This is useful if you wish to embed it directly in your script.'

      param 'CONFIG_PATH', <<~USAGE
        Path to the YAML configuration file [default: completely.yaml].
        Use '-' to read from stdin.
        
        Can also be set by an environment variable.
      USAGE

      param 'OUTPUT_PATH', <<~USAGE
        Path to the output bash script.
        Use '-' for stdout.
        
        When not provided, the name of the input file will be used with a .bash extension, unless the input is stdin - in this case the default will be to output to stdout.
        
        Can also be set by an environment variable.
      USAGE

      environment_config_path
      environment 'COMPLETELY_OUTPUT_PATH', 'Path to the output bash script.'
      environment_debug

      def run
        wrap = args['--wrap']
        output = wrap ? wrapper_function(wrap) : script
        if output_path == '-'
          puts output
        else
          File.write output_path, output
          say "Saved m`#{output_path}`"
        end
        syntax_warning unless completions.valid?
      end

    private

      def wrapper_function(wrapper_name)
        completions.wrapper_function wrapper_name
      end
    end
  end
end
