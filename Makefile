SHELL := /bin/bash

.PHONY: all clean docker-tools cloudflare-ddns other-tools

all: docker-tools cloudflare-ddns other-tools

# Define docker-tools target to build the deb package
docker-tools: check-help2man docker-tools.deb
	@echo "Docker tools build process completed."

docker-tools.deb: docker_backup_volume docker_prune docker_restore_volume
	@echo "Building Docker tools Debian package..." && \
	mkdir -p build/docker-tools-deb/usr/local/bin && \
	mkdir -p build/docker-tools-deb/DEBIAN && \
	echo "Copying files..." && \
	cp build_templates/docker-tools-control.template build/docker-tools-deb/DEBIAN/control && \
	cp docker_backup_volume docker_prune docker_restore_volume build/docker-tools-deb/usr/local/bin/ && \
	chmod 755 build/docker-tools-deb/usr/local/bin/* && \
	mkdir -p build/docker-tools-deb/usr/share/man/man1 && \
	echo "Generating man pages..." && \
	help2man -N --no-info --output=build/docker-tools-deb/usr/share/man/man1/docker_backup_volume.1 build/docker-tools-deb/usr/local/bin/docker_backup_volume || true && \
	help2man -N --no-info --output=build/docker-tools-deb/usr/share/man/man1/docker_prune.1 build/docker-tools-deb/usr/local/bin/docker_prune || true && \
	help2man -N --no-info --output=build/docker-tools-deb/usr/share/man/man1/docker_restore_volume.1 build/docker-tools-deb/usr/local/bin/docker_restore_volume || true && \
	echo "Building deb package..." && \
	dpkg-deb --build build/docker-tools-deb && \
	mkdir -p dist && \
	mv build/docker-tools-deb.deb dist/docker-tools.deb && \
	echo "Docker tools Debian package built successfully: dist/docker-tools-deb.deb"

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
	@if ! command -v help2man >/dev/null 2>&1; then \
		echo "WARNING: help2man is not installed. Man pages will not be generated."; \
		echo "To install help2man, run: sudo apt-get install help2man"; \
		read -p "Do you want to install help2man? (y/n): " choice ; \
		while [[ ! "$$choice" =~ ^[YyNn]$$ ]]; do \
			echo "Invalid input. Please enter 'y' or 'n'."; \
			read -p "Do you want to install help2man? (y/n): " choice; \
		done; \
		if [[ "$$choice" =~ ^[Yy]$$ ]]; then \
			echo "Installing help2man."; \
			sudo apt-get update && sudo apt-get install -y help2man; \
		fi; \
	fi;

clean:
	@rm -rf build dist && echo "Done"

clean-docker-tools:
	@rm -rf build/docker-tools-deb && rm dist/docker-tools.deb && echo "Done"

uninstall:
	@echo "Uninstalling Docker tools..." && \
	sudo apt purge docker-tools -y;
	@echo "Uninstalling Cloudflare DDNS" && \
	sudo rm -f /usr/local/bin/cloudflared_dynamic_dns_ipv6 && \
	echo "Cloudflare DDNS uninstalled successfully.";

