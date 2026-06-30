describe 'generated pattern config script' do
  subject { Completions.load config_path }

  let(:config_path) { File.expand_path("../fixtures/pattern-config/#{fixture}.yaml", __dir__) }

  let(:response) do
    Dir.chdir 'spec/fixtures/integration' do
      subject.tester.test(compline).sort
    end
  end

  config = YAML.load_file 'spec/completely/pattern_config_integration.yml'

  config.each do |fixture, use_cases|
    use_cases.each do |use_case|
      describe "#{fixture} ▶ '#{use_case['compline']}'" do
        let(:fixture) { fixture }
        let(:compline) { use_case['compline'] }
        let(:expected) { use_case['expected'] }

        it "returns #{use_case['expected'].join ' '}" do
          expect(response).to eq expected
        end
      end
    end
  end
end
