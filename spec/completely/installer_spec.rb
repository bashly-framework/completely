describe Installer do
  subject { described_class.new program: program, script_path: script_path }

  let(:leeway) { RUBY_VERSION < '3.2.0' ? 0 : 3 }
  let(:program) { 'completely-test' }
  let(:script_path) { 'completions.bash' }
  let(:targets) { subject.target_directories.map { |dir| "#{dir}/#{program}" } }
  let(:install_command) do
    %W[sudo cp #{subject.script_path} #{subject.target_path}]
  end

  let(:uninstall_command) do
    %w[sudo rm -f] + targets
  end

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

  describe '#target_directories' do
    it 'returns an array of potential completion directories' do
      expect(subject.target_directories).to be_an Array
      expect(subject.target_directories.size).to eq 4
    end
  end

  describe '#target_path' do
    it 'returns the first matching path' do
      expect(subject.target_path)
        .to eq '/usr/share/bash-completion/completions/completely-test'
    end
  end

  describe '#install_command' do
    it 'returns a copy command as an array' do
      expect(subject.install_command)
        .to eq %w[sudo cp completions.bash /usr/share/bash-completion/completions/completely-test]
    end

    context 'when the user is root' do
      it 'returns the command without sudo' do
        allow(subject).to receive(:root_user?).and_return true

        expect(subject.install_command)
          .to eq %w[cp completions.bash /usr/share/bash-completion/completions/completely-test]
      end
    end
  end

  describe '#install_command_string' do
    it 'returns the install command as a string' do
      expect(subject.install_command_string).to eq subject.install_command.join(' ')
    end
  end

  describe '#uninstall_command' do
    it 'returns an rm command as an array' do
      expect(subject.uninstall_command).to eq %w[sudo rm -f] + targets
    end

    context 'when the user is root' do
      it 'returns the command without sudo' do
        allow(subject).to receive(:root_user?).and_return true

        expect(subject.uninstall_command).to eq %w[rm -f] + targets
      end
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
    end

    context 'when the completions_path cannot be found' do
      it 'raises an error' do
        allow(subject).to receive(:completions_path).and_return nil

        expect { subject.install }.to raise_approval('installer/install-no-dir')
          .diff(leeway)
      end
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

        expect(subject).to receive(:system).with(*install_command)

        subject.install force: true
      end
    end

    context 'when the target does not exist' do
      it 'proceeds to install' do
        allow(subject).to receive(:target_path).and_return missing_file

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
