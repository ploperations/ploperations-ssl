# frozen_string_literal: true

require 'spec_helper'

describe 'ssl::ensure_newline' do
  on_supported_os.each do |os, _os_facts|
    context "on #{os}" do
      context 'when the string already ends with a newline character' do
        it {
          is_expected.to run.with_params(
            "spec tests are fun!\n",
          ).and_return(
            "spec tests are fun!\n",
          )
        }
      end

      context 'when the string does not end with a newline character' do
        it {
          is_expected.to run.with_params(
            'I am going to get a newline!',
          ).and_return(
            "I am going to get a newline!\n",
          )
        }
      end
    end
  end
end
