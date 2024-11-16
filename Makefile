YAMLS := $(patsubst %.yaml.erb,%.yaml,$(wildcard */*.yaml.erb *.yaml.erb))

.PHONY: clean all check deploy
all: $(YAMLS)

clean:
	rm -rf $(YAMLS)

check: all
	promtool check config prometheus.yml

deploy: clean all check

%.yaml: %.yaml.erb build.rb
	./build.rb < $(@).erb > $@
	chown $(USER):prometheus $@

# rules.yaml: build.rb rules.yaml.erb
# 	make clean rules.yaml.tmp
# 	promtool check rules rules.yaml.tmp
# 	mv rules.yaml.tmp rules.yaml
# 	chown tramfjord:prometheus rules.yaml
# 	cp rules.yaml /etc/prometheus/rules.yaml
# 	sudo systemctl reload prometheus
