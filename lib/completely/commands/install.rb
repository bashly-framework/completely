require 'completely/commands/base'

module Completely
  module Commands
    class Install < Base
      summary 'Install a bash completion script'

      help <<~HELP
        This command will copy the specified file to one of the bash completion directories.
        The target filename will be the program name, and sudo will be used if necessary.
      HELP

      usage 'completely install PROGRAM [SCRIPT_PATH --force --dry]'
      usage 'completely install (-h|--help)'

      option '-f --force', 'Overwrite target file if it exists'
      option '-d --dry', 'Show the installation command but do not run it'

      param 'PROGRAM', 'Name of the program the completions are for.'
      param 'SCRIPT_PATH', 'Path to the source bash script [default: completely.bash].'

      def run
        if args['--dry']
          puts installer.install_command_string
          return
        end

        success = installer.install force: args['--force']
        raise InstallError, "Failed running command:\nnb`#{installer.install_command_string}`" unless success

        say "Saved m`#{installer.target_path}`"
        say 'You may need to restart your session to test it'
      end

    private

      def installer
        @installer ||= Installer.new(program: args['PROGRAM'], script_path: script_path)
      end

      def script_path
        @script_path ||= args['SCRIPT_PATH'] || 'completely.bash'
      end
    end
  end
end
