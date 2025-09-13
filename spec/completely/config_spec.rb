describe Config do
  subject { described_class.load path }

  let(:path) { "spec/fixtures/#{file}.yaml" }
  let(:file) { 'nested' }
  let(:config_string) { "cli: [--help, --version]" }
  let(:config_hash) { { 'cli' => %w[--help --version] } }

  describe '::parse' do
    it 'loads config from string' do
      expect(described_class.parse(config_string).config).to eq config_hash
    end

    context 'when the string is not a valid YAML' do
      it 'raises ParseError' do
        expect { described_class.parse("not: a: yaml") }.to raise_error(Completely::ParseError)
      end
    end
  end

  describe '::read' do
    it 'loads config from io' do
      io = double :io, read: config_string
      expect(described_class.read(io).config).to eq config_hash
    end
  end

  describe '#flat_config' do
    it 'returns a flat pattern => completions hash' do
      expect(subject.flat_config.to_yaml).to match_approval('config/flat_config')
    end
  end

  context 'when complete_options is defined' do
    let(:file) { 'complete_options' }

    describe 'config' do
      it 'ignores the completely_config YAML key' do
        expect(subject.config.keys).to eq ['mygit']
      end
    end

    describe 'options' do
      it 'returns the completely_options hash from the YAML file' do
        expect(subject.options[:complete_options]).to eq '-o nosort'
      end
    end
  end
end
