describe Commands::Uninstall do
  subject { described_class.new }

  let(:leeway) { RUBY_VERSION < '3.2.0' ? 0 : 5 }
  let :mock_installer do
    instance_double Installer,
      uninstall:                true,
      uninstall_command_string: 'rm -f some paths'
  end

  context 'with --help' do
    it 'shows long usage' do
      expect { subject.execute %w[uninstall --help] }
        .to output_approval('cli/uninstall/help')
    end
  end

  context 'without arguments' do
    it 'shows short usage' do
      expect { subject.execute %w[uninstall] }
        .to output_approval('cli/uninstall/no-args')
    end
  end

  context 'with PROGRAM' do
    it 'invokes the Installer' do
      allow(subject).to receive(:installer).and_return(mock_installer)

      expect(mock_installer).to receive(:uninstall)

      expect { subject.execute %w[uninstall completely-test] }
        .to output_approval('cli/uninstall/uninstall')
    end
  end

  context 'with PROGRAM --dry' do
    it 'shows the command and does not install anything' do
      expect(mock_installer).not_to receive(:uninstall)

      expect { subject.execute %w[uninstall completely-test --dry] }
        .to output_approval('cli/uninstall/dry')
        .except(%r[/home/([^/]+)], '/home/USER')
        .diff(20)
    end
  end

  context 'when the installer fails' do
    it 'raises an error' do
      allow(subject).to receive(:installer).and_return(mock_installer)
      allow(mock_installer).to receive(:uninstall).and_return false

      expect { subject.execute %w[uninstall completely-test] }
        .to raise_approval('cli/uninstall/uninstall-error').diff(leeway)
    end
  end
end
