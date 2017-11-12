# frozen_string_literal: true

RSpec.describe 'Lieutenant::VERSION' do
  subject { Lieutenant::VERSION }

  it { is_expected.to be_a(String) }

  it 'follows semantic versioning' do
    is_expected.to match(/\d+\.\d+\.\d+/)
  end
end
