describe Commands::Test do
  subject { described_class.new }

  before do
    system 'cp lib/completely/templates/flat-config/sample.yaml completely.yaml'
    ENV['COMPLETELY_CONFIG_PATH'] = nil
  end

  after do
    system 'rm -f completely.yaml'
    ENV['COMPLETELY_CONFIG_PATH'] = nil
  end

  context 'with --help' do
    it 'shows long usage' do
      expect { subject.execute %w[test --help] }.to output_approval('cli/test/help')
    end
  end

  context 'without arguments' do
    it 'shows a short usage' do
      expect { subject.execute %w[test] }
        .to output_approval('cli/test/usage')
    end
  end

  context 'with COMPLINE' do
    it 'prints completions' do
      expect { subject.execute ['test', 'mygit --'] }
        .to output_approval('cli/test/comps-default')
    end
  end

  context 'with --keep COMPLINE' do
    before { system "rm -f #{filename}" }
    after { system "rm -f #{filename}" }

    let(:filename) { 'completely-tester-1.sh' }

    it 'copies the test script to the current directory' do
      expect { subject.execute ['test', '--keep', 'mygit status --'] }
        .to output_approval('cli/test/comps-default-keep')

      expect(File.read filename).to match_approval('cli/test/completely-tester.sh')
    end
  end

  context 'with COMPLINE COMPLINE' do
    it 'prints multiple completions' do
      expect { subject.execute ['test', 'mygit --', 'mygit s'] }
        .to output_approval('cli/test/comps-multi')
    end
  end

  context 'with --keep COMPLINE COMPLINE' do
    before { filenames.each { |filename| system "rm -f #{filename}" } }
    after { filenames.each { |filename| system "rm -f #{filename}" } }

    let(:filenames) { ['completely-tester-1.sh', 'completely-tester-2.sh'] }

    it 'copies the test scripts to the current directory' do
      expect { subject.execute ['test', '--keep', 'mygit --', 'mygit st'] }
        .to output_approval('cli/test/comps-multi-keep')

      expect(File.read filenames[0]).to match_approval('cli/test/completely-tester-1.sh')
      expect(File.read filenames[1]).to match_approval('cli/test/completely-tester-2.sh')
    end
  end

  context 'when COMPLETELY_CONFIG_PATH is set' do
    before do
      reset_tmp_dir
      File.write 'spec/tmp/in.yaml', { 'play' => %w[command conquer] }.to_yaml
      ENV['COMPLETELY_CONFIG_PATH'] = 'spec/tmp/in.yaml'
    end

    it 'tests against this completely file' do
      expect { subject.execute ['test', 'play co'] }
        .to output_approval('cli/test/comps-custom-config')
    end
  end

  context 'when there is no completely.yaml or COMPLETELY_CONFIG_PATH' do
    before { system 'rm -f completely.yaml' }

    it 'fails gracefully' do
      expect { subject.execute ['test', 'mygit --'] }
        .to raise_approval('cli/test/error')
    end
  end

  context 'with an invalid configuration' do
    before do
      reset_tmp_dir
      File.write 'spec/tmp/in.yaml', { 'one' => %w[anything], 'two' => %w[something] }.to_yaml
      ENV['COMPLETELY_CONFIG_PATH'] = 'spec/tmp/in.yaml'
    end

    it 'outputs a warning to STDERR' do
      expect { subject.execute %w[test on] }.to output_approval('cli/warning').to_stderr
    end
  end
end
