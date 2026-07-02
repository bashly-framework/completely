describe PatternConfig do
  subject(:config) { Config.load 'spec/fixtures/pattern-config/basic.yaml' }

  describe '#model' do
    it 'returns the command name' do
      expect(config.model[:program]).to eq 'mygit'
    end

    it 'returns program names from all patterns' do
      expect(config.model[:programs]).to eq %w[mygit mygit]
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
          source: { items: [{ type: :value, value: '$(echo main dev)' }] },
        }
      )
    end

    it 'returns token sources' do
      expect(config.model[:tokens]).to eq(
        'directory' => { items: [{ type: :builtin, value: 'directory' }] },
        'branch'    => { items: [{ type: :value, value: '$(echo main dev)' }] }
      )
    end

    it 'returns the command tree root' do
      tree = config.model[:tree]

      expect(tree[:word]).to eq(name: 'mygit', aliases: [])
      expect(tree[:option_groups]).to eq []
      expect(tree[:positionals]).to eq []
    end

    it 'returns child command nodes' do
      children = config.model[:tree][:children]

      expect(children.map { |child| child[:word] }).to eq [
        { name: 'init', aliases: [] },
        { name: 'status', aliases: ['st'] },
      ]
    end

    it 'returns child node option groups and positionals' do
      init, status = config.model[:tree][:children]

      expect(init[:option_groups]).to eq ['init']
      expect(init[:positionals]).to eq [
        { name: 'directory', source: { items: [{ type: :builtin, value: 'directory' }] } },
      ]
      expect(status[:option_groups]).to eq ['status']
      expect(status[:positionals]).to eq []
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

    it 'returns an empty source' do
      expect(config.model[:tokens]['source']).to eq(items: [])
    end

    it 'uses the empty source for positionals' do
      expect(config.model[:tree][:children].first[:positionals].first).to eq(
        name:   'source',
        source: { items: [] }
      )
    end
  end

  context 'with a mixed token source' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/mixed-source.yaml' }

    it 'returns builtin and value items' do
      expect(config.model[:tokens]['target']).to eq(
        items: [
          { type: :builtin, value: 'directory' },
          { type: :value, value: 'target1' },
          { type: :value, value: '$(echo target2)' },
        ]
      )
    end

    it 'escapes literal values that start with +' do
      expect(config.model[:tokens]['value']).to eq(
        items: [{ type: :value, value: '+file' }]
      )
    end
  end

  context 'with a repeatable option' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/repeatable.yaml' }

    let(:name_source) do
      {
        items: [
          { type: :value, value: 'alice' },
          { type: :value, value: 'bob' },
        ],
      }
    end

    it 'marks repeatable options' do
      expect(config.model[:options]['download'].last).to eq(
        names:      ['-u', '--user'],
        repeatable: true,
        value:      {
          name:   'name',
          source: name_source,
        }
      )
    end
  end

  context 'with repeatable positionals' do
    subject(:config) { Config.load 'spec/fixtures/pattern-config/repeatable-positionals.yaml' }

    let(:file_source) do
      {
        items: [
          { type: :value, value: 'file1' },
          { type: :value, value: 'file2' },
        ],
      }
    end

    it 'marks repeatable positionals' do
      expect(config.model[:tree][:children].first[:positionals]).to eq [
        {
          name:       'file',
          repeatable: true,
          source:     file_source,
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

  context 'with option groups between command words' do
    subject(:config) do
      Config.parse <<~YAML
        patterns:
          - docker [global options] container [container options]
          - docker [global options] container push [push options] <container>

        options:
          global:
            - --config <file>
          container:
            - --context <context>
          push:
            - --all-tags

        tokens:
          file: +file
          context: [default, remote]
          container: [app, worker]
      YAML
    end

    it 'attaches option groups to the command node where they appear' do
      tree = config.model[:tree]
      container = tree[:children].first
      push = container[:children].first

      expect(tree[:option_groups]).to eq ['global']
      expect(container[:option_groups]).to eq ['container']
      expect(push[:option_groups]).to eq ['push']
    end

    it 'keeps positionals on the command node where they appear' do
      push = config.model[:tree][:children].first[:children].first

      expect(push[:positionals]).to eq [
        {
          name:   'container',
          source: { items: [{ type: :value, value: 'app' }, { type: :value, value: 'worker' }] },
        },
      ]
    end
  end
end
