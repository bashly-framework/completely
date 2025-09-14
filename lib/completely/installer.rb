module Completely
  class Installer
    class << self
      def from_io(program:, io: nil)
        io ||= $stdin

        raise InstallError, "io must respond to #read" unless io.respond_to?(:read)
        raise InstallError, "io is closed" if io.respond_to?(:closed?) && io.closed?

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
        tempfile = Tempfile.new ["completely-", '.bash']
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

    def target_directories
      @target_directories ||= %W[
        /usr/share/bash-completion/completions
        /usr/local/etc/bash_completion.d
        #{Dir.home}/.local/share/bash-completion/completions
        #{Dir.home}/.bash_completion.d
      ]
    end

    def install_command
      result = root_user? ? [] : %w[sudo]
      result + %W[cp #{script_path} #{target_path}]
    end

    def install_command_string
      install_command.join ' '
    end

    def uninstall_command
      result = root_user? ? [] : %w[sudo]
      result + %w[rm -f] + target_directories.map { |dir| "#{dir}/#{program}" }
    end

    def uninstall_command_string
      uninstall_command.join ' '
    end

    def target_path
      "#{completions_path}/#{program}"
    end

    def install(force: false)
      unless completions_path
        raise InstallError, 'Cannot determine system completions directory'
      end

      unless script_exist?
        raise InstallError, "Cannot find script: m`#{script_path}`"
      end

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

    def root_user?
      Process.uid.zero?
    end

    def completions_path
      @completions_path ||= begin
        result = nil
        target_directories.each do |target|
          if Dir.exist? target
            result = target
            break
          end
        end

        result
      end
    end
  end
end
