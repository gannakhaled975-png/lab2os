DIR = test_dir
MDIR = malicious_dir
INTERVAL = 5
.PHONY: setup run restore
setup:
	mkdir -p $(MDIR)
run: setup
	./antivirusd.sh $(DIR) $(MDIR) $(INTERVAL)
restore: setup
	./restore.sh $(DIR) $(MDIR)

