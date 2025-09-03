SHELL := /bin/bash

.PHONY: all clean convenient-bash-tools cloudflare-ddns other-tools build

all: convenient-bash-tools cloudflare-ddns other-tools build

# Define build target
build: convenient-bash-tools
	@echo "Build processes completed."

# Define convenient-bash-tools target to build the deb package
convenient-bash-tools: check-help2man convenient-bash-tools.deb
	@echo "Docker tools build process completed."

convenient-bash-tools.deb: docker_backup_volume docker_prune docker_restore_volume
	@echo "Building bash tools Debian package..." && \
	mkdir -p build/convenient-bash-tools-deb/usr/local/bin && \
	mkdir -p build/convenient-bash-tools-deb/usr/share/convenient-bash-tools && \
	mkdir -p build/convenient-bash-tools-deb/etc/bash_completion.d && \
	mkdir -p build/convenient-bash-tools-deb/usr/share/man/man1 && \
	mkdir -p build/convenient-bash-tools-deb/DEBIAN && \
	echo "Checking docker installation..." && \
	if ! command -v docker > /dev/null 2>&1; then \
		echo "WARNING: docker is not installed."; \
		if [[ -n "$$DEBIAN_NONINTERACTIVE" ]]; then \
  			echo "DEBIAN_NONINTERACTIVE is set. Installing docker automatically."; \
  			choice="y"; \
		else \
			read -p "Do you want to install docker? (y/n): " choice ; \
			while [[ ! "$$choice" =~ ^[YyNn]$$ ]]; do \
				echo "Invalid input. Please enter 'y' or 'n'."; \
				read -p "Do you want to install docker? (y/n): " choice; \
			done; \
		fi; \
		if [[ "$$choice" =~ ^[Yy]$$ ]]; then \
			echo "Installing docker."; \
			sudo apt-get update && \
			sudo apt-get install ca-certificates curl && \
			sudo install -m 0755 -d /etc/apt/keyrings && \
			sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
			sudo chmod a+r /etc/apt/keyrings/docker.asc && \
			echo \
			  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
			  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
			  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
			sudo apt-get update && \
			sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
			sudo usermod -aG docker $USER && \
			newgrp docker;
		fi; \
	fi && \
	echo "Downloading complete_alias" && \
	wget -q --show-progress -O build/convenient-bash-tools-deb/usr/share/convenient-bash-tools/complete_alias https://raw.githubusercontent.com/cykerway/complete-alias/refs/heads/master/complete_alias; \
	echo "Copying files..." && \
	cp build_templates/DEBIAN/control build/convenient-bash-tools-deb/DEBIAN/control && \
	cp docker_prune docker_backup_volume docker_restore_volume mkbash set_turbo turbo_status build/convenient-bash-tools-deb/usr/local/bin/ && \
	cp to.sh venv_activate.sh build/convenient-bash-tools-deb/usr/share/convenient-bash-tools  && \
	cp build_templates/etc/bash_completion.d/bash_tools build/convenient-bash-tools-deb/etc/bash_completion.d && \
	chmod 755 build/convenient-bash-tools-deb/usr/local/bin/* && \
	echo "Generating man pages..." && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/docker_backup_volume.1 build/convenient-bash-tools-deb/usr/local/bin/docker_backup_volume || true && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/docker_prune.1 build/convenient-bash-tools-deb/usr/local/bin/docker_prune || true && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/docker_restore_volume.1 build/convenient-bash-tools-deb/usr/local/bin/docker_restore_volume || true && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/set_turbo.1 build/convenient-bash-tools-deb/usr/local/bin/set_turbo || true && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/turbo_status.1 build/convenient-bash-tools-deb/usr/local/bin/turbo_status || true && \
	help2man -N --no-info --output=build/convenient-bash-tools-deb/usr/share/man/man1/mkbash.1 build/convenient-bash-tools-deb/usr/local/bin/mkbash || true && \
	echo "Building deb package..." && \
	dpkg-deb --build build/convenient-bash-tools-deb && \
	mkdir -p dist && \
	mv build/convenient-bash-tools-deb.deb dist/convenient-bash-tools.deb && \
	echo "Docker tools Debian package built successfully: dist/convenient-bash-tools-deb.deb"

cloudflare-ddns: cloudflared_dynamic_dns_ipv6.py
	@sudo cp cloudflared_dynamic_dns_ipv6.py /usr/local/bin/cloudflared_dynamic_dns_ipv6 && \
	sudo chmod a+x /usr/local/bin/cloudflared_dynamic_dns_ipv6 && \
	crontab -l > mycron && \
	echo "*/30 * * * * /usr/local/bin/cloudflared_dynamic_dns_ipv6" >> mycron && \
	crontab mycron && \
	rm mycron && \
	echo "Done. Run cloudflared_dynamic_dns_ipv6 once to confirm that it works"

other-tools:
	# Add other tools here as needed

.PHONY: check-help2man
check-help2man:
	@if ! command -v help2man > /dev/null 2>&1; then \
		echo "WARNING: help2man is not installed. Man pages will not be generated."; \
		echo "To install help2man, run: sudo apt-get install help2man"; \
		if [[ -n "$$DEBIAN_NONINTERACTIVE" ]]; then \
  			echo "DEBIAN_NONINTERACTIVE is set. Installing help2man automatically."; \
  			choice="y"; \
		else \
			read -p "Do you want to install help2man? (y/n): " choice ; \
			while [[ ! "$$choice" =~ ^[YyNn]$$ ]]; do \
				echo "Invalid input. Please enter 'y' or 'n'."; \
				read -p "Do you want to install help2man? (y/n): " choice; \
			done; \
		fi; \
		if [[ "$$choice" =~ ^[Yy]$$ ]]; then \
			echo "Installing help2man."; \
			sudo apt-get update && sudo apt-get install -y help2man; \
		fi; \
	fi;

clean:
	@rm -rf build dist && echo "Done"

clean-convenient-bash-tools:
	@rm -rf build/convenient-bash-tools-deb && rm dist/convenient-bash-tools.deb && echo "Done"

uninstall:
	@echo "Uninstalling Docker tools..." && \
	sudo apt purge convenient-bash-tools -y;
	@echo "Uninstalling Cloudflare DDNS" && \
	sudo rm -f /usr/local/bin/cloudflared_dynamic_dns_ipv6 && \
	echo "Cloudflare DDNS uninstalled successfully.";

