# Standard ERB files (1:1 mapping)
ERBS := $(patsubst %.erb,%,$(wildcard prometheus/*/*.erb prometheus/*.erb alertmanager/*.erb))

# Dynamic targets from services.yml using yq
VPN_SERVICES := $(shell yq -r '.services[] | select(.uses_vpn == true) | .name' services.yml)
VPN_SERVICE_UNITS := $(addprefix systemd/,$(addsuffix .service,$(VPN_SERVICES)))

# All generated files
GENERATED := $(ERBS) $(VPN_SERVICE_UNITS) systemd/wireguard.service docker-compose.yml

.PHONY: clean all check deploy systemd gitignore

all: $(ERBS) systemd docker-compose.yml gitignore

systemd: systemd/wireguard.service $(VPN_SERVICE_UNITS)

clean:
	rm -rf $(ERBS) $(VPN_SERVICE_UNITS) systemd/wireguard.service docker-compose.yml

check: all
	promtool check config prometheus/prometheus.yml
	amtool check-config alertmanager/alertmanager.yml

deploy: check
	chown -R $(USER):prometheus prometheus/
	cp -r prometheus/* /etc/prometheus/
	sudo systemctl reload prometheus
	sudo systemctl reload prometheus-blackbox-exporter
	sudo cp -r alertmanager/* /etc/alertmanager/
	sudo chown -R root:root /etc/alertmanager
	sudo systemctl reload alertmanager

# Standard ERB rendering (1:1 mapping)
$(ERBS): %: %.erb render.rb services.yml
	./render.rb < $@.erb > $@

# Wireguard service (uses vpn_gateway and vpn_services in template)
systemd/wireguard.service: systemd/wireguard.service.erb render.rb services.yml
	./render.rb < $< > $@

# VPN-dependent services (pattern rule)
$(VPN_SERVICE_UNITS): systemd/%.service: systemd/vpn-service.service.erb render.rb services.yml
	SERVICE_NAME=$* ./render.rb < $< > $@

# Docker Compose file
docker-compose.yml: docker-compose.yml.erb render.rb services.yml
	./render.rb < $< > $@

# Update .gitignore with generated files
gitignore:
	@echo "# Auto-generated files (do not edit this section)" > .gitignore.generated
	@for f in $(GENERATED); do echo "$$f" >> .gitignore.generated; done
	@if [ -f .gitignore ]; then \
		sed '/^# Auto-generated files/,/^# End auto-generated/d' .gitignore > .gitignore.tmp && mv .gitignore.tmp .gitignore; \
	fi
	@cat .gitignore.generated >> .gitignore
	@echo "# End auto-generated" >> .gitignore
	@rm .gitignore.generated
