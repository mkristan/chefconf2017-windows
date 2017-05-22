resource_name :net_adapter

provides :net_adapter, platform: 'windows' do |node|
    ::Gem::Version.new(node['platform_version']) >= ::Gem::Version.new('6.2')
end

property :interface_alias, String, name_property: true
property :interface_index, Integer

load_current_value do |desired|
    require 'chef/util/powershell/cmdlet'
    interface_command = if desired.interface_index.nil?
                            "Get-NetAdapter -InterfaceAlias #{desired.interface_alias}"
                        else
                            "Get-NetAdapter -InterfaceIndex #{desired.interface_index}"
                        end
    interface_cim_object = (Chef::Util::Powershell::Cmdlet.new(node, interface_command, :object).run!).return_value
    interface_index interface_cim_object['InterfaceIndex'].to_i
    interface_alias interface_cim_object['InterfaceAlias']
end

action :rename do
    new_resource.interface_alias new_resource.name unless property_is_set? :interface_alias

    converge_if_changed :interface_alias do
        powershell_out!("Get-NetAdapter -InterfaceIndex #{current_resource.interface_index} | Rename-NetAdapter -NewName #{new_resource.interface_alias}")
    end
end

