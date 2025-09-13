module Completely
  class Installer
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
        target_directories.each do |target|
          return target if Dir.exist? target
        end

        nil
      end
    end
  end
end
