# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet-utils'

def mock_file_function(return_value)
  MockFunction.new('file').expected.returns(return_value).at_least(:once)
end

describe 'ssl' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      before(:each) { mock_file_function('pem-formatted-data') }

      let(:facts) { os_facts }

      let(:params) do
        {
          'cert_source' => 'profile/ssl',
          'keys'        => {
            'www.example.com' => 'some-private-key-data',
          },
        }
      end

      context 'with custom group_name' do
        context 'managed by the module' do
          let(:params) do
            {
              'cert_source'  => 'profile/ssl',
              'group_name'   => 'custom-group',
              'keys'         => {
                'www.example.com' => 'some-private-key-data',
              },
            }
          end

          it { is_expected.to contain_group('custom-group') }

          case os_facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_file('/etc/pki/private').with_ensure('directory').with_group('custom-group') }
          else
            it { is_expected.to contain_file('/etc/ssl/private').with_ensure('directory').with_group('custom-group') }
          end
        end

        context 'managed outside the module' do
          let(:params) do
            {
              'cert_source'  => 'profile/ssl',
              'group_name'   => 'custom-group',
              'keys'         => {
                'www.example.com' => 'some-private-key-data',
              },
              'manage_group' => false,
            }
          end

          let(:pre_condition) { '@group { "custom-group": ensure => present, }' }

          it { is_expected.to contain_group('custom-group') }

          case os_facts[:os]['family']
          when 'RedHat'
            it { is_expected.to contain_file('/etc/pki/private').with_ensure('directory').with_group('custom-group') }
          else
            it { is_expected.to contain_file('/etc/ssl/private').with_ensure('directory').with_group('custom-group') }
          end
        end

        context 'not declared in the catalog should fail' do
          let(:params) do
            {
              'cert_source'  => 'profile/ssl',
              'group_name'   => 'custom-group',
              'keys'         => {
                'www.example.com' => 'some-private-key-data',
              },
              'manage_group' => false,
            }
          end

          it { is_expected.not_to compile }
        end
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('ssl::params') }
      it { is_expected.to contain_group('ssl-cert') }

      case os_facts[:os]['family']
      when 'RedHat'
        it { is_expected.to contain_file('/etc/pki').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/pki/certs').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/pki/private').with_ensure('directory') }
      else
        it { is_expected.to contain_file('/etc/ssl').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/ssl/certs').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/ssl/private').with_ensure('directory') }
      end
    end
  end
end
