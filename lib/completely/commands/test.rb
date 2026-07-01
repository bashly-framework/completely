require 'completely/commands/base'

module Completely
  module Commands
    class Test < Base
      summary 'Test completions'

      help 'This command can be used to test that your completions script responds with ' \
        'the right completions. It works by reading a Completely YAML configuration file, ' \
        'generating a completions script, and generating a temporary testing script.'

      usage 'completely test [--keep] COMPLINE...'
      usage 'completely test (-h|--help)'

      option '-k --keep', 'Keep the temporary testing script in the current directory.'

      param 'COMPLINE', 'One or more commands to test completions for. ' \
        'This will be handled as if a TAB was pressed immediately at the end of it, ' \
        'so the last word is considered the active cursor. ' \
        'If you wish to complete for the next word instead, end your command with a space.'

      environment_config_path
      environment_debug

      example 'completely test "mygit "'
      example 'completely test --keep "mygit status "'
      example 'completely test "mygit status --" "mygit init "'

      def run
        complines.each_with_index do |compline, i|
          show_compline compline, filename: "completely-tester-#{i + 1}.sh"
        end

        syntax_warning unless completions.valid?
      end

    private

      def show_compline(compline, filename: nil)
        filename ||= 'completely-tester.sh'
        say "b`$` g`#{compline}`<tab>"
        puts tester.test(compline).join "\n"
        puts

        return unless keep

        File.write filename, tester_script(compline)
        say "Saved m`#{filename}`"
      end

      def complines
        @complines ||= args['COMPLINE']
      end

      def keep
        @keep ||= args['--keep']
      end

      def completions
        @completions ||= Completions.load config_path
      end

      def tester
        @tester ||= completions.tester
      end

      def tester_script(compline)
        tester.tester_script compline
      end
    end
  end
end
