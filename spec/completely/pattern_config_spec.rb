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
      expect(config.model[:options]['init']).to eq [{ names: ['--bare'], repeatable: false }]
    end

    it 'returns status flag options' do
      expect(config.model[:options]['status'].first).to eq(
        names:      ['--verbose', '-v'],
        repeatable: false
      )
    end

    it 'returns status options with values' do
      expect(config.model[:options]['status'].last).to eq(
        names:      ['--branch', '-b'],
        repeatable: false,
        value:      {
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

  context 'when complete_options is defined' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/complete_options.yaml' }

    describe 'config' do
      it 'ignores the completely_options YAML key' do
        expect(config.config.keys).to eq %w[patterns tokens]
      end
    end

    describe 'options' do
      it 'returns the completely_options hash from the YAML file' do
        expect(config.options[:complete_options]).to eq '-o nosort'
      end
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

  context 'with a nil token source' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/nil-source.yaml' }

    it 'returns a none source' do
      expect(config.model[:tokens]['source']).to eq(type: :none)
    end

    it 'uses the none source for positionals' do
      expect(config.model[:routes].first[:positionals].first).to eq(
        name:   'source',
        source: { type: :none }
      )
    end
  end

  context 'with a repeatable option' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/repeatable.yaml' }

    it 'marks repeatable options' do
      expect(config.model[:options]['download'].last).to eq(
        names:      ['-u', '--user'],
        repeatable: true,
        value:      {
          name:   'name',
          source: { type: :values, value: %w[alice bob] },
        }
      )
    end
  end

  context 'with repeatable positionals' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/repeatable-positionals.yaml' }

    it 'marks repeatable positionals' do
      expect(config.model[:routes].first[:positionals]).to eq [
        {
          name:       'file',
          repeatable: true,
          source:     { type: :values, value: %w[file1 file2] },
        },
      ]
    end
  end

  context 'with a non-final repeatable positional' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/repeatable-positionals-invalid.yaml' }

    it 'raises ParseError' do
      expect { config.model }.to raise_error(
        Completely::ParseError,
        'Repeatable positional must be the last positional in pattern: cli copy <source>... <target>'
      )
    end
  end

  context 'with unknown option metadata' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/unknown-metadata.yaml' }

    it 'raises ParseError' do
      expect { config.model }.to raise_error Completely::ParseError, 'Unknown option metadata: (hidden)'
    end
  end
end
