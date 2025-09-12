describe Commands::Generate do
  subject { described_class.new }

  before do
    reset_tmp_dir
    system 'cp lib/completely/templates/sample.yaml completely.yaml'
  end

  after do
    system 'rm -f completely.yaml'
  end

  context 'with --help' do
    it 'shows long usage' do
      expect { subject.execute %w[generate --help] }.to output_approval('cli/generate/help')
    end
  end

  context 'without arguments' do
    it 'generates the bash script to completely.bash' do
      expect { subject.execute %w[generate] }.to output_approval('cli/generate/no-args')
      expect(File.read 'completely.bash').to match_approval('cli/generated-script')
    end

    it 'generates a shellcheck compliant script' do
      expect { subject.execute %w[generate] }.to output_approval('cli/generate/no-args')
      expect(`shellcheck completely.bash 2>&1`).to be_empty
    end

    it 'generates a shfmt compliant script' do
      expect { subject.execute %w[generate] }.to output_approval('cli/generate/no-args')
      expect(`shfmt -d -i 2 -ci completely.bash 2>&1`).to be_empty
    end
  end

  context 'with CONFIG_PATH' do
    it 'generates the bash script to completely.bash' do
      expect { subject.execute %w[generate completely.yaml] }.to output_approval('cli/generate/custom-path')
      expect(File.read 'completely.bash').to match_approval('cli/generated-script')
    end
  end

  context 'with COMPLETELY_CONFIG_PATH env var' do
    before do
      reset_tmp_dir
      system 'cp lib/completely/templates/sample.yaml spec/tmp/hello.yml'
      system 'rm -f completely.yaml'
      ENV['COMPLETELY_CONFIG_PATH'] = 'spec/tmp/hello.yml'
    end

    after do
      ENV['COMPLETELY_CONFIG_PATH'] = nil
      system 'rm -f hello.bash'
    end

    it 'generates the bash script to hello.bash' do
      expect { subject.execute %w[generate] }.to output_approval('cli/generate/custom-path-env')
      expect(File.read 'hello.bash').to match_approval('cli/generated-script')
    end
  end

  context 'with COMPLETELY_OUTPUT_PATH env var' do
    let(:outfile) { 'spec/tmp/tada.bash' }

    before do
      reset_tmp_dir
      ENV['COMPLETELY_OUTPUT_PATH'] = outfile
    end

    after do
      ENV['COMPLETELY_OUTPUT_PATH'] = nil
    end

    it 'generates the bash script to the requested path' do
      expect { subject.execute %w[generate] }.to output_approval('cli/generate/custom-path-env2')
      expect(File.read outfile).to match_approval('cli/generated-script')
    end
  end

  context 'with CONFIG_PATH OUTPUT_PATH' do
    before { reset_tmp_dir }

    it 'generates the bash script to the specified path' do
      expect { subject.execute %w[generate completely.yaml spec/tmp/out.bash] }
        .to output_approval('cli/generate/custom-out-path')
      expect(File.read 'spec/tmp/out.bash').to match_approval('cli/generated-script')
    end
  end

  context 'with stdin and stdout' do
    it 'reads config from stdin and writes to stdout' do
      allow($stdin).to receive(:tty?).and_return false
      allow($stdin).to receive(:read).and_return File.read('completely.yaml')

      expect { subject.execute %w[generate -] }
        .to output_approval('cli/generated-script')
    end
  end

  context 'with stdin and output path' do
    let(:outfile) { 'spec/tmp/stdin-to-file.bash' }

    it 'reads config from stdin and writes to file' do
      allow($stdin).to receive(:tty?).and_return false
      allow($stdin).to receive(:read).and_return File.read('completely.yaml')

      expect { subject.execute %W[generate - #{outfile}] }.to output_approval('cli/generate/custom-path-stdin')
      expect(File.read outfile).to match_approval('cli/generated-script')
    end
  end

  context 'with --function NAME' do
    after { system 'rm -f completely.bash' }

    it 'uses the provided function name' do
      expect { subject.execute %w[generate --function _mycomps] }.to output_approval('cli/generate/function')
      expect(File.read 'completely.bash').to match_approval('cli/generated-script-alt')
    end
  end

  context 'with --wrapper NAME' do
    after { system 'rm -f completely.bash' }

    it 'wraps the script in a function' do
      expect { subject.execute %w[generate --wrap give_comps] }.to output_approval('cli/generate/wrapper')
      expect(File.read 'completely.bash').to match_approval('cli/generated-wrapped-script')
    end
  end

  context 'with an invalid configuration' do
    it 'outputs a warning to STDERR' do
      expect { subject.execute %w[generate spec/fixtures/broken.yaml spec/tmp/out.bash] }
        .to output_approval('cli/warning').to_stderr
    end
  end
end
