ERBS := $(patsubst %.erb,%,$(wildcard */*/*.erb */*.erb))

.PHONY: clean all check deploy
all: $(ERBS)

clean:
	rm -rf $(ERBS)

check: all
	promtool check config prometheus/prometheus.yml
	amtool check-config alertmanager/alertmanager.yml

deploy: check
	cp -r prometheus/* /etc/prometheus/
	sudo systemctl reload prometheus
	sudo systemctl reload prometheus-blackbox-exporter
	sudo cp -r alertmanager/* /etc/alertmanager/
	sudo chown -R root:root /etc/alertmanager
	sudo systemctl reload alertmanager

$(ERBS): %: %.erb render.rb services.yml
	./render.rb < $@.erb > $@
	chown $(USER):prometheus $@
