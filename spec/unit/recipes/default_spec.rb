#
# Cookbook:: mwwfy
# Spec:: default
#
# Copyright:: 2017, Michael Kristan
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'spec_helper'

describe 'mwwfy::default' do
  context 'When all attributes are default, on the Windows 2012 R2 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    context 'file[c:\hello.txt]' do
      it 'sets Read for Everyone' do
        expect(chef_run).to create_file('c:\hello.txt').with(
            rights: [{ permissions: :full_control, principals: 'ChefPowerShell' },
                     { permissions: :read, principals: 'Everyone' }]
          )
      end
    end
  end
end
