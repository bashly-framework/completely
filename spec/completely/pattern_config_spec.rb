describe PatternConfig do
  subject(:config) { Config.load 'spec/fixtures/pattern-config/basic.yaml' }

  describe '#model' do
    it 'returns the command name' do
      expect(config.model[:program]).to eq 'mygit'
    end

    it 'returns route words' do
      words = config.model[:routes].map { |route| route[:words] }

      expect(words).to eq [
        [{ name: 'mygit', aliases: [] }, { name: 'init', aliases: [] }],
        [{ name: 'mygit', aliases: [] }, { name: 'status', aliases: ['st'] }],
      ]
    end

    it 'returns route option groups' do
      option_groups = config.model[:routes].map { |route| route[:option_groups] }

      expect(option_groups).to eq [['init'], ['status']]
    end

    it 'returns route positionals' do
      positionals = config.model[:routes].map { |route| route[:positionals] }

      expect(positionals).to eq [
        [{ name: 'directory', source: { type: :builtin, value: 'directory' } }],
        [],
      ]
    end

    it 'returns init options' do
      expect(config.model[:options]['init']).to eq [{ names: ['--bare'] }]
    end

    it 'returns status flag options' do
      expect(config.model[:options]['status'].first).to eq({ names: ['--verbose', '-v'] })
    end

    it 'returns status options with values' do
      expect(config.model[:options]['status'].last).to eq(
        names: ['--branch', '-b'],
        value: {
          name:   'branch',
          source: { type: :command, value: '$(echo main dev)' },
        }
      )
    end

    it 'returns token sources' do
      expect(config.model[:tokens]).to eq(
        'directory' => { type: :builtin, value: 'directory' },
        'branch'    => {
          type:  :command,
          value: '$(echo main dev)',
        }
      )
    end
  end

  describe '#flat_config' do
    it 'does not convert pattern config to flat config' do
      expect { config.flat_config }
        .to raise_error Completely::Error, 'Pattern config cannot be converted to flat config'
    end
  end

  context 'with a missing option group' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/missing-option.yaml' }

    it 'raises ParseError' do
      expect { config.model }.to raise_error Completely::ParseError, 'Unknown option group: missing'
    end
  end

  context 'with a missing token' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/missing-token.yaml' }

    it 'raises ParseError' do
      expect { config.model }.to raise_error Completely::ParseError, 'Unknown token: directory'
    end
  end
end
