.PHONY: requirements ping setup-all setup-services setup-services-reset lint

requirements:
	ansible-galaxy install -r requirements.yml

ping:
	ansible -i inventory all -m ping

setup-all:
	ansible-playbook -i inventory playbook.yml --ask-vault-pass

setup-services:
	ansible-playbook -i inventory playbook.yml --ask-vault-pass --tags "swarm-services"

setup-services-reset:
	ansible-playbook -i inventory playbook.yml --ask-vault-pass --tags "swarm-services" --extra-vars "reset=true"

lint:
	ansible-lint playbook.yml

.PHONY: setup-all generate-ssh-key distribute-ssh-key run-playbook

SSH_KEY_PATH = ~/.ssh/id_rsa_vcc

setup-all: generate-ssh-key distribute-ssh-key run-playbook

generate-ssh-key:
	@if [ ! -f $(SSH_KEY_PATH) ]; then \
		ssh-keygen -t rsa -b 2048 -f $(SSH_KEY_PATH) -N ""; \
	fi

distribute-ssh-key:
	@for host in 192.168.73.10 192.168.73.11 192.168.73.12; do \
		sshpass -p "vagrant" ssh-copy-id -i $(SSH_KEY_PATH).pub vagrant@$$host; \
	done

run-playbook:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory playbook.yml --extra-vars "ansible_ssh_private_key_file=$(SSH_KEY_PATH)"

