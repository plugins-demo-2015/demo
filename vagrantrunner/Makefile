.PHONY: run

run:
	vagrant up --parallel
	chmod 0600 insecure_public_key insecure_private_key
	bash flocker.sh
	bash weave.sh
