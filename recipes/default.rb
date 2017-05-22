#
# Cookbook:: mwwfy
# Recipe:: default
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

reboot 'Restarting for fun and profit' do
    action :nothing
    reason 'Because I can'
    delay_mins 1
end

file 'c:\hello.txt' do
    content "Chef's going to reboot your server. Ha ha"
    action :create
    notifies :reboot_now, 'reboot[Restarting for fun and profit]', :immediately
    rights :full_control, 'ChefPowerShell'
    rights :read, 'Everyone'
end

powershell_script 'Chocolatey' do
  code <<-EOH
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  EOH
  not_if 'Test-Path $env:programdata\chocolatey\bin\choco.exe'
end

dsc_resource 'IIS' do
  resource :windowsfeature
  property :name, 'web-server'
end

x_web_administration_version = '1.17.0.0'

powershell_package "xWebAdministration" do
    version x_web_administration_version
end

dsc_resource 'Default Web Site' do
    resource :xWebSite
    module_name 'xWebAdministration'
    module_version x_web_administration_version
    property :name, 'Default Web Site'
    property :state, 'Stopped'
end

dsc_resource 'ChefConf Workshop Site' do
    resource :xWebSite
    module_name 'xWebAdministration'
    module_version x_web_administration_version
    property :name, 'ChefConf'
end

net_adapter "Local" do
    interface_index 2
end

user node['mwwfy']['alternate_user'] do
    comment 'another'
    password node['mwwfy']['alternate_password']
    action :create
end

puts "Alternate User from Mixlib::Shellout"
puts (Mixlib::ShellOut.new('whoami.exe', 
    :user => node['mwwfy']['alternate_user'], 
    :password => node['mwwfy']['alternate_password'])).run_command.stdout
