##
##  Makefile -- Build procedure for Trusterd HTTP/2 Web Server
##	  MATSUMOTO, Ryosuke
##

PWD=$(shell pwd)
TRUSTERD_ROOT=$(PWD)
MRUBY_ROOT=$(PWD)/mruby
INSTALL_PREFIX=$(TRUSTERD_ROOT)/build


#   the default target
all: trusterd

#   compile binary
trusterd:
	git submodule init
	git submodule update
	cd $(MRUBY_ROOT) && cp -f ../build_config.rb . && rake
	cp -p $(MRUBY_ROOT)/bin/mruby $(TRUSTERD_ROOT)/bin/trusterd

mini-trusterd:
	git submodule init
	git submodule update
	cd $(MRUBY_ROOT) && cp -f ../build_config.rb . && rake
	cd src/ && make

# 	test
test:
	cd $(MRUBY_ROOT) && cp -f ../build_config.rb . && rake all test

#   install
install:
	install -d $(INSTALL_PREFIX)/bin $(INSTALL_PREFIX)/htdocs $(INSTALL_PREFIX)/ssl $(INSTALL_PREFIX)/conf $(INSTALL_PREFIX)/logs
	install -m 755 $(TRUSTERD_ROOT)/bin/trusterd $(INSTALL_PREFIX)/bin/.
	sed -e 's|root_dir = "/usr/local/trusterd"|root_dir = "$(INSTALL_PREFIX)"|' $(TRUSTERD_ROOT)/conf/trusterd.conf.rb  > $(INSTALL_PREFIX)/conf/trusterd.conf.rb
	echo hello trusterd world. > $(INSTALL_PREFIX)/htdocs/index.html
	echo 'rputs JSON::stringify({:now => Time.now.to_s, :message => "hello world"})' > $(INSTALL_PREFIX)/htdocs/hello.rb

#   cleanup
clean:
	-rm -rf $(TRUSTERD_ROOT)/bin/trusterd
	cd $(MRUBY_ROOT) && rake deep_clean
	cd $(MRUBY_ROOT) && git checkout HEAD .

#   the general trusterd start/restart/stop procedures
restart: stop start
start:
	$(INSTALL_PREFIX)/bin/trusterd $(INSTALL_PREFIX)/conf/trusterd.conf.rb
stop:
	killall trusterd

.PHONY: test
