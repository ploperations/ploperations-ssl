# frozen_string_literal: true

require 'spec_helper'

describe 'ssl::pem::join' do
  on_supported_os.each do |os, _os_facts|
    context "on #{os}" do
      context 'when one string already ends with a newline character' do
        it {
          is_expected.to run.with_params([
                                           'I am going to get a newline!',
                                           "spec tests are fun!\n",
                                         ]).and_return(
                                           "I am going to get a newline!\nspec tests are fun!\n",
                                         )
        }
      end

      context 'when no string ends with a newline character' do
        it {
          is_expected.to run.with_params([
                                           'I am going to get a newline!',
                                           'spec tests are fun!',
                                         ]).and_return(
                                           "I am going to get a newline!\nspec tests are fun!\n",
                                         )
        }
      end
    end
  end
end
