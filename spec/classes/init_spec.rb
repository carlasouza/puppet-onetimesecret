require 'spec_helper'
describe 'ontimesecret' do

  context 'with defaults for all parameters' do
    it { should contain_class('ontimesecret') }
  end
end
