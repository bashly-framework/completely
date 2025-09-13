describe Completions do
  subject { described_class.load path }

  let(:path) { "spec/fixtures/#{file}.yaml" }
  let(:file) { 'basic' }

  describe '::read' do
    it 'reads from io' do
      io = double :io, read: "cli: [--help, --version]"
      expect(described_class.read(io).config.config).to eq({ 'cli' => %w[--help --version] })
    end
  end

  describe '#valid?' do
    context 'when all patterns start with the same word' do
      it 'returns true' do
        expect(subject).to be_valid
      end
    end

    context 'when not all patterns start with the same word' do
      let(:file) { 'broken' }

      it 'returns false' do
        expect(subject).not_to be_valid
      end
    end
  end

  describe '#patterns' do
    it 'returns an array of Pattern objects' do
      expect(subject.patterns).to be_an Array
      expect(subject.patterns.first).to be_a Pattern
    end
  end

  describe '#script' do
    it 'returns a bash completions script' do
      expect(subject.script).to match_approval 'completions/script'
    end

    context 'with a configuration file that only includes patterns with spaces' do
      let(:file) { 'only-spaces' }

      it 'uses the first word of the first command as the function name' do
        expect(subject.script).to match_approval 'completions/script-only-spaces'
      end
    end

    context 'when COMPLETELY_DEBUG is set' do
      before { ENV['COMPLETELY_DEBUG'] = '1' }
      after  { ENV['COMPLETELY_DEBUG'] = nil }

      it 'adds an additional debug snippet to the script' do
        expect(subject.script).to match_approval('completions/script-with-debug')
          .except(/case.*/m)
      end
    end

    context 'with a configuration file that includes complete_options' do
      let(:file) { 'complete_options' }

      it 'adds the complete_options to the complete command' do
        expect(subject.script).to match_approval 'completions/script-complete-options'
      end
    end
  end

  describe '#wrapper_function' do
    it 'returns the script wrapped inside a function' do
      expect(subject.wrapper_function).to match_approval 'completions/function'
    end
  end

  describe '#tester' do
    it 'returns a Tester object' do
      expect(subject.tester).to be_a Tester
    end

    it 'assigns self.script to tester.script' do
      expect(subject.tester.script).to eq subject.script
    end
  end
end
