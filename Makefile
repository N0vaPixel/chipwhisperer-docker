DEVICE_DESC = $(shell lsusb | grep "2b3e:")
BUS_ID = $(shell echo $(DEVICE_DESC) | awk '{print $$2}')
DEVICE_ID = $(shell echo $(DEVICE_DESC) | awk '{print $$4}' | sed 's/://')
DESCRIPTOR = "/dev/bus/usb/$(BUS_ID)/$(DEVICE_ID)"

PROJECT = cw
CONFIGS = bare jupyter

.PHONY: .check clean

$(CONFIGS):%: .check .dockerbuild-$(PROJECT)-%
	docker run -it --rm -p 8888:8888 \
		--security-opt label=disable \
	    --device $(DESCRIPTOR) \
	    -u user \
	    --userns=keep-id \
	    -v ./work:/home/user/work \
	    -h $(PROJECT)-$@ \
	    --name $(PROJECT)-$@ \
	    $(PROJECT)-$@

.check:
	@if [ "$(DEVICE_DESC)" != "" ]; then \
		echo "Device found: $(DEVICE_DESC)"; \
		if [[ -r "$(DESCRIPTOR)" && -w "$(DESCRIPTOR)" ]]; then \
			echo "Device permissions: OK"; \
		else \
			echo "Device permissions: FAILED. Please check you udev rules\nExiting.."; \
			exit 1; \
		fi; \
	else \
		echo -e "Device not found in host\nExiting.."; \
		exit 1; \
	fi;

.dockerbuild-$(PROJECT)-%: Dockerfile.$(PROJECT)-% shell_env.sh
	docker build -t $(PROJECT)-$* -f Dockerfile.$(PROJECT)-$*  | tee /dev/stderr | tail -1 >> .dockerbuild-$(PROJECT)-$*

clean:
	docker image rm $$(cat .dockerbuild-*); rm .dockerbuild-$(PROJECT)*