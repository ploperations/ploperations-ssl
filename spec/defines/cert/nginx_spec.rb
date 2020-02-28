# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet-utils'

def mock_file_function(return_value)
  MockFunction.new('file').expected.returns(return_value).at_least(:once)
end

describe 'ssl::cert::nginx' do
  let(:title) { 'www.example.com' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      before(:each) { mock_file_function('pem-formatted-data') }

      let(:facts) { os_facts }

      let(:pre_condition) do
        "class { ssl:
          cert_source => 'profile/ssl',
          keys        => {
            'www.example.com' => 'some-private-key-data',
          },
        }"
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('ssl') }

      case os_facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_file('/etc/pki/private/www.example.com.key').with_ensure('file') }
        it { is_expected.to contain_file('/etc/pki/certs/www.example.com.crt').with_ensure('file') }
      else
        it { is_expected.to contain_file('/etc/ssl/private/www.example.com.key').with_ensure('file') }
        it { is_expected.to contain_file('/etc/ssl/certs/www.example.com.crt').with_ensure('file') }
      end
    end
  end
end
