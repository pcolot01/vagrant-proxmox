module VagrantPlugins
	module Proxmox
		module Action

			# This action creates a new virtual machine on the Proxmox server and
			# stores its node and vm_id env[:machine].id
			class CreateVm < ProxmoxAction

				def initialize app, env
					@app = app
					@logger = Log4r::Logger.new 'vagrant_proxmox::action::create_vm'
				end

				def call env
					env[:ui].info I18n.t('vagrant_proxmox.creating_vm')
					config = env[:machine].provider_config

					node = env[:proxmox_selected_node]
					vm_id = nil

					begin
						vm_id = connection(env).get_free_vm_id
						params = create_params_lxc(config, env, vm_id) if config.vm_type == :lxc
						params = create_params_qemu(config, env, vm_id) if config.vm_type == :qemu
						exit_status = connection(env).create_vm node: node, vm_type: config.vm_type, params: params
						exit_status == 'OK' ? exit_status : raise(VagrantPlugins::Proxmox::Errors::ProxmoxTaskFailed, proxmox_exit_status: exit_status)
					rescue StandardError => e
						raise VagrantPlugins::Proxmox::Errors::VMCreateError, proxmox_exit_status: e.message
					end

					env[:machine].id = "#{node}/#{vm_id}"

					env[:ui].info I18n.t('vagrant_proxmox.done')
					next_action env
				end

				private
				def create_params_qemu(config, env, vm_id)
					network = "#{config.qemu_nic_model},bridge=#{config.qemu_bridge}"
					network = "#{config.qemu_nic_model}=#{get_machine_macaddress(env)},bridge=#{config.qemu_bridge}" if get_machine_macaddress(env)
					{vmid: vm_id,
					 name: env[:machine].config.vm.hostname || env[:machine].name.to_s,
					 ostype: config.qemu_os,
					 ide2: "#{config.qemu_iso},media=cdrom",
					 sata0: "#{config.qemu_storage}:#{config.qemu_disk_size},format=qcow2",
					 sockets: config.qemu_sockets,
					 cores: config.qemu_cores,
					 memory: config.vm_memory,
					 net0: network,
					 description: "#{config.vm_name_prefix}#{env[:machine].name}"}
				end
                
                private
				def create_params_lxc(config, env, vm_id)
					{vmid: vm_id,
					 ostemplate: config.lxc_os_template,
					 hostname: env[:machine].config.vm.hostname || env[:machine].name.to_s,
					 password: "#{config.vm_root_password}",
					 rootfs: "#{config.vm_storage}:#{config.vm_disk_size}",
					 memory: config.vm_memory,
					 description: "#{config.vm_name_prefix}#{env[:machine].name}"}
					.tap do |params|					
						net_num = 0
						env[:machine].config.vm.networks.each do |type, options|
						next if not type.match(/^p.*_network$/)
							nic = "name=#{options[:interface]}"
							nic += ",ip=#{options[:ip]}#{options[:cidr_block]}" if options[:ip] && options[:cidr_block]
							nic += ",gw=#{options[:gw]}" if options[:gw]
							nic += ",bridge=#{options[:bridge]}" if options[:bridge]
							net = 'net' + net_num.to_s
							params[net] = nic
							net_num += 1
						end		
					end
				end
			end
		end
	end
end
