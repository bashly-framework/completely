require 'completely/commands/base'

module Completely
  module Commands
    class Preview < Base
      help 'Generate the bash completion script to stdout'

      usage 'completely preview [CONFIG_PATH --function NAME]'
      usage 'completely preview (-h|--help)'

      option_function
      param_config_path
      environment_config_path
      environment_debug

      def run
        puts script
        syntax_warning unless completions.valid?
      end
    end
  end
end
