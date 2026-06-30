describe PatternConfig do
  subject(:config) { Config.load 'spec/fixtures/pattern-config/basic.yaml' }

  describe '#model' do
    it 'returns the command name' do
      expect(config.model[:program]).to eq 'mygit'
    end

    it 'returns routes from the completion patterns' do
      expect(config.model[:routes]).to eq [
        {
          words: [
            { name: 'mygit', aliases: [] },
            { name: 'init', aliases: [] },
          ],
          option_groups: ['init'],
          positionals: [
            {
              name: 'directory',
              source: { type: :builtin, value: 'directory' },
            },
          ],
        },
        {
          words: [
            { name: 'mygit', aliases: [] },
            { name: 'status', aliases: ['st'] },
          ],
          option_groups: ['status'],
          positionals: [],
        },
      ]
    end

    it 'returns option groups' do
      expect(config.model[:options]).to eq(
        'init' => [
          { names: ['--bare'] },
        ],
        'status' => [
          { names: ['--verbose', '-v'] },
          {
            names: ['--branch', '-b'],
            value: {
              name: 'branch',
              source: {
                type: :command,
                value: '$(echo main dev)',
              },
            },
          },
        ]
      )
    end

    it 'returns token sources' do
      expect(config.model[:tokens]).to eq(
        'directory' => { type: :builtin, value: 'directory' },
        'branch' => {
          type: :command,
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
