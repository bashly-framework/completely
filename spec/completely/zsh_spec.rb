describe 'zsh compatibility' do
  subject do
    Dir.chdir 'spec/tmp' do
      `#{shell} test.sh`.strip
    end
  end

  let(:completions) { Completely::Completions.load 'spec/fixtures/flat-config/basic.yaml' }
  let(:words) { 'completely generate ' }
  let(:tester_script) { completions.tester.tester_script words }
  let(:shell) { 'zsh' }

  before do
    reset_tmp_dir
    system 'mkdir -p spec/tmp/somedir'
    File.write 'spec/tmp/test.sh', tester_script
  end

  describe 'completions script and test script' do
    it 'returns completions without erroring' do
      expect(subject).to eq 'somedir'
    end

    context 'when running on bash shell' do
      let(:shell) { 'bash' }

      it 'returns the same output' do
        expect(subject).to eq 'somedir'
      end
    end
  end
end
