#!/bin/bash
#######################
#      Variables      #
#######################
VM_NAME="Ubuntu Server"		# Name of the virtual machine
RAM=""				# RAM base
VDI_PATH=""			# VDI file
OS="Ubuntu_64"			# Operating system
NET_ADAPTERS="--nic1 nat --nictype1 virtio --nic2 intnet --nictype2 virtio --intnet2 CONFINAMENT "		# Network adapters
SSH="--natpf1 "SSH,tcp,127.0.0.1,22,,22"	# Adds SSH tunnel from NAT to local host

############################
#        Creates VM        #
############################
# Checks if any virtual machine with $VM_NAME already exists
if [[ VBoxManage list vms | grep -q "$NOMMV" ]]; then 
   echo "$VM_NAME already exists. Do you want to delete it and start anew? (Y/N)"
   read -e answer
   if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
      VBoxManage controlvm "$VM_NAME" poweroff; sleep 1
      VBoxManage unregistervm --delete "$VM_NAME"; sleep 1
   else
      exit
   fi
fi

# Creates new virtual machine from VDI file
VBoxManage createvm --name "$VM_NAME" -register --ostype $OS
VBoxManage storagectl "$VM_NAME" --name jgdiscos --add ide
VBoxManage storageattach "$VM_NAME" --storagectl jgdiscos --port 0 --device 0 --type hdd --medium "$VDI_PATH" --mtype immutable
VBoxManage modifyvm "$VM_NAME" --ostype $OS --ioapic off --memory $RAM --vram 32 --pae on --hwvirtex on --boot1 disk --audio none --accelerate3d on --usb off "
VBoxManage startvm "$NOMMV" --type headless # Type headless will start machine with no window. Make sure OpenSSH is installed so you can connect by CLI.