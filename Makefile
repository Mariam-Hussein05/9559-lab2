DIR = labtest
MALICIOUS_DIR = quarantine
INTERVAL = 10

run: prepare
	bash antivirusd.sh $(DIR) $(MALICIOUS_DIR) $(INTERVAL)

restore: prepare
	bash restore.sh $(DIR) $(MALICIOUS_DIR)

prepare:
	mkdir -p $(MALICIOUS_DIR)
