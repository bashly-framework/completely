describe Commands::Init do
  subject { described_class.new }

  before { system 'rm -f completely.yaml' }
  after  { system 'rm -f completely.yaml' }

  let(:sample) { File.read 'lib/completely/templates/flat-config/sample.yaml' }
  let(:sample_nested) { File.read 'lib/completely/templates/flat-config/sample-nested.yaml' }
  let(:sample_pattern) { File.read 'lib/completely/templates/pattern-config/sample.yaml' }

  context 'with --help' do
    it 'shows long usage' do
      expect { subject.execute %w[init --help] }.to output_approval('cli/init/help')
    end
  end

  context 'without arguments' do
    it 'creates a new sample file named completely.yaml' do
      expect { subject.execute %w[init] }.to output_approval('cli/init/no-args')
      expect(File.read 'completely.yaml').to eq sample_pattern
    end
  end

  context 'with --format flat' do
    it 'creates a sample using the flat configuration' do
      expect { subject.execute %w[init --format flat] }.to output_approval('cli/init/flat')
      expect(File.read 'completely.yaml').to eq sample
    end
  end

  context 'with --format nested' do
    it 'creates a sample using the nested configuration' do
      expect { subject.execute %w[init --format nested] }.to output_approval('cli/init/nested')
      expect(File.read 'completely.yaml').to eq sample_nested
    end
  end

  context 'with --format pattern' do
    it 'creates a sample using the pattern configuration' do
      expect { subject.execute %w[init --format pattern] }.to output_approval('cli/init/pattern')
      expect(File.read 'completely.yaml').to eq sample_pattern
    end
  end

  context 'with an invalid format' do
    it 'raises an error' do
      expect { subject.execute %w[init --format invalid] }.to raise_approval('cli/init/invalid-format')
    end
  end

  context 'with CONFIG_PATH' do
    before { reset_tmp_dir }

    it 'creates a new sample file with the requested name' do
      expect { subject.execute %w[init spec/tmp/in.yaml] }
        .to output_approval('cli/init/custom-path')
      expect(File.read 'spec/tmp/in.yaml').to eq sample_pattern
    end
  end

  context 'with COMPLETELY_CONFIG_PATH env var' do
    before do
      reset_tmp_dir
      ENV['COMPLETELY_CONFIG_PATH'] = 'spec/tmp/hello.yml'
    end

    after { ENV['COMPLETELY_CONFIG_PATH'] = nil }

    it 'creates a new sample file with the requested name' do
      expect { subject.execute %w[init] }
        .to output_approval('cli/init/custom-path-env')
      expect(File.read 'spec/tmp/hello.yml').to eq sample_pattern
    end
  end

  context 'when the config file already exists' do
    before { system 'cp lib/completely/templates/flat-config/sample.yaml completely.yaml' }
    after  { system 'rm -f completely.yaml' }

    it 'raises an error' do
      expect { subject.execute %w[init] }.to raise_approval('cli/init/file-exists')
    end
  end
end
