# frozen_string_literal: true

require 'spec_helper'

describe 'ssl::hashfile' do
  let(:title) { '/tmp/www.example.com.crt' }
  let(:params) do
    {
      'certdir' => '/certs',
    }
  end

  let(:pre_condition) do
    "file { '/certs/www.example.com.crt':
      ensure => file,
    }"
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it {
        is_expected.to contain_exec('Build cert hash for www.example.com.crt')
          .with_command('ln -s /certs/www.example.com.crt /certs/$(openssl x509 -noout -hash -in /certs/www.example.com.crt).0')
      }
    end
  end
end
