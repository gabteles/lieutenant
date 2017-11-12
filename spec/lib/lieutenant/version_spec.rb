# frozen_string_literal: true

RSpec.describe 'Lieutenant::VERSION' do
  it { is_expected.to be_a(String) }

  it 'follows semantic versioning' do
    is_expected.to match(/\d+\.\d+\.\d+/)
  end
end
