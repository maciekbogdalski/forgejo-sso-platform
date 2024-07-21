.PHONY: requirements ping setup-all setup-services setup-services-reset lint

requirements:
	ansible-galaxy install -r requirements.yml

ping:
	ansible -i inventory all -m ping

setup-all:
	ansible-playbook -i inventory install_collections.yml
	ansible-playbook -i inventory deploy_ssh_keys.yml
	ansible-playbook -i inventory playbook.yml --vault-password-file ~/.ansible_vault_password

setup-services:
	ansible-playbook -i inventory playbook.yml --vault-password-file ~/.ansible_vault_password --tags "swarm-services"

setup-services-reset:
	ansible-playbook -i inventory playbook.yml --vault-password-file ~/.ansible_vault_password --tags "swarm-services" --extra-vars "reset=true"

lint:
	ansible-lint playbook.yml

.PHONY: setup-all generate-ssh-key distribute-ssh-key run-playbook

SSH_KEY_PATH = ~/.ssh/id_rsa_vcc

generate-ssh-key:
	@if [ ! -f $(SSH_KEY_PATH) ]; then \
		ssh-keygen -t rsa -b 2048 -f $(SSH_KEY_PATH) -N ""; \
	fi

distribute-ssh-key:
	@for host in 192.168.177.10 192.168.177.11 192.168.177.12; do \
		sshpass -p "vagrant" ssh-copy-id -i $(SSH_KEY_PATH).pub vagrant@$$host || true; \
	done

run-playbook:
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory install_collections.yml
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory deploy_ssh_keys.yml
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory playbook.yml --vault-password-file ~/.ansible_vault_password --extra-vars "ansible_ssh_private_key_file=$(SSH_KEY_PATH)"
