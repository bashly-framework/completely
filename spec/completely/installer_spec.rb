describe Installer do
  subject { described_class.new program: program, script_path: script_path }

  let(:leeway) { RUBY_VERSION < '3.2.0' ? 0 : 3 }
  let(:program) { 'completely-test' }
  let(:script_path) { 'completions.bash' }
  let(:target_path) { "#{Dir.home}/.local/share/bash-completion/completions/#{program}" }
  let(:install_command) { %W[cp #{subject.script_path} #{subject.target_path}] }
  let(:uninstall_command) { %W[rm -f #{subject.target_path}] }

  describe '::from_io' do
    subject { described_class.from_io program:, io: }

    let(:io) { StringIO.new 'dummy data' }

    it 'reads the script from io and writes it to a temp file' do
      expect(File.read subject.script_path).to eq 'dummy data'
    end
  end

  describe '::from_string' do
    subject { described_class.from_string program:, string: }

    let(:string) { 'dummy data' }

    it 'reads the script from io and writes it to a temp file' do
      expect(File.read subject.script_path).to eq 'dummy data'
    end
  end

  describe '#target_path' do
    it 'returns a user-level target path' do
      expect(subject.target_path).to eq target_path
    end

    context 'when BASH_COMPLETION_USER_DIR is set' do
      around do |example|
        original = ENV['BASH_COMPLETION_USER_DIR']
        ENV['BASH_COMPLETION_USER_DIR'] = '/tmp/completely-user-dir'
        example.run
      ensure
        ENV['BASH_COMPLETION_USER_DIR'] = original
      end

      it 'uses BASH_COMPLETION_USER_DIR/completions' do
        expect(subject.target_path).to eq '/tmp/completely-user-dir/completions/completely-test'
      end
    end

    context 'when XDG_DATA_HOME is set' do
      around do |example|
        original = ENV['XDG_DATA_HOME']
        ENV['XDG_DATA_HOME'] = '/tmp/completely-xdg'
        example.run
      ensure
        ENV['XDG_DATA_HOME'] = original
      end

      it 'uses XDG_DATA_HOME/bash-completion/completions' do
        expect(subject.target_path).to eq '/tmp/completely-xdg/bash-completion/completions/completely-test'
      end
    end

    context 'when BASH_COMPLETION_USER_DIR has multiple entries' do
      around do |example|
        original = ENV['BASH_COMPLETION_USER_DIR']
        ENV['BASH_COMPLETION_USER_DIR'] = ':/tmp/completely-first:/tmp/completely-second'
        example.run
      ensure
        ENV['BASH_COMPLETION_USER_DIR'] = original
      end

      it 'uses the first non-empty entry' do
        expect(subject.target_path).to eq '/tmp/completely-first/completions/completely-test'
      end
    end
  end

  describe '#install_command' do
    it 'returns a copy command as an array' do
      expect(subject.install_command)
        .to eq %W[cp completions.bash #{target_path}]
    end
  end

  describe '#install_command_string' do
    it 'returns the install command as a string' do
      expect(subject.install_command_string).to eq subject.install_command.join(' ')
    end
  end

  describe '#uninstall_command' do
    it 'returns an rm command as an array' do
      expect(subject.uninstall_command).to eq %W[rm -f #{target_path}]
    end
  end

  describe '#uninstall_command_string' do
    it 'returns the uninstall command as a string' do
      expect(subject.uninstall_command_string).to eq subject.uninstall_command.join(' ')
    end
  end

  describe '#install' do
    let(:existing_file) { 'spec/fixtures/existing-file.txt' }
    let(:missing_file) { 'tmp/missing-file' }

    before do
      allow(subject).to receive_messages(script_path: existing_file, target_path: missing_file)
      allow(FileUtils).to receive(:mkdir_p)
    end

    context 'when the script cannot be found' do
      it 'raises an error' do
        allow(subject).to receive(:script_path).and_return missing_file

        expect { subject.install }.to raise_approval('installer/install-no-script')
          .diff(leeway)
      end
    end

    context 'when the target exists' do
      it 'raises an error' do
        allow(subject).to receive(:target_path).and_return existing_file

        expect { subject.install }.to raise_approval('installer/install-target-exists')
          .diff(leeway)
      end
    end

    context 'when the target exists but force=true' do
      it 'proceeds to install' do
        allow(subject).to receive(:target_path).and_return existing_file

        expect(FileUtils).to receive(:mkdir_p)
        expect(subject).to receive(:system).with(*install_command)

        subject.install force: true
      end
    end

    context 'when the target does not exist' do
      it 'proceeds to install' do
        allow(subject).to receive(:target_path).and_return missing_file

        expect(FileUtils).to receive(:mkdir_p)
        expect(subject).to receive(:system).with(*install_command)

        subject.install
      end
    end
  end

  describe '#uninstall' do
    it 'removes the completions script' do
      expect(subject).to receive(:system).with(*uninstall_command)

      subject.uninstall
    end
  end
end
