require 'fileutils'

module Completely
  class Installer
    class << self
      def from_io(program:, io: nil)
        io ||= $stdin

        raise InstallError, 'io must respond to #read' unless io.respond_to?(:read)
        raise InstallError, 'io is closed' if io.respond_to?(:closed?) && io.closed?

        from_string program:, string: io.read
      end

      def from_string(program:, string:)
        tempfile = create_tempfile
        script_path = tempfile.path
        begin
          File.write script_path, string
        ensure
          tempfile.close
        end

        new program:, script_path:
      end

      def create_tempfile
        tempfile = Tempfile.new ['completely-', '.bash']
        tempfiles.push tempfile
        tempfile
      end

      def tempfiles = @tempfiles ||= []
    end

    attr_reader :program, :script_path

    def initialize(program:, script_path: nil)
      @program = program
      @script_path = script_path
    end

    def install_command
      %W[cp #{script_path} #{target_path}]
    end

    def install_command_string
      install_command.join ' '
    end

    def uninstall_command
      %W[rm -f #{target_path}]
    end

    def uninstall_command_string
      uninstall_command.join ' '
    end

    def target_path
      "#{completions_path}/#{program}"
    end

    def install(force: false)
      unless script_exist?
        raise InstallError, "Cannot find script: m`#{script_path}`"
      end

      FileUtils.mkdir_p completions_path

      if target_exist? && !force
        raise InstallError, "File exists: m`#{target_path}`"
      end

      system(*install_command)
    end

    def uninstall
      system(*uninstall_command)
    end

  private

    def target_exist?
      File.exist? target_path
    end

    def script_exist?
      File.exist? script_path
    end

    def completions_path
      @completions_path ||= "#{user_completions_base_dir}/completions"
    end

    def user_completions_base_dir
      @user_completions_base_dir ||= bash_completion_user_dir || "#{data_home}/bash-completion"
    end

    def bash_completion_user_dir
      ENV['BASH_COMPLETION_USER_DIR']&.split(':')&.find { |entry| !entry.empty? }
    end

    def data_home
      ENV['XDG_DATA_HOME'] || "#{Dir.home}/.local/share"
    end
  end
end
