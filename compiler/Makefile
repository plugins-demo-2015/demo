.PHONY: compile

compile:
	bash bootstrap.sh
	vagrant up compiler
	bash compile.sh
	bash copyresults.sh
	vagrant suspend builder
