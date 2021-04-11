######################################################################
# Makefile user configuration
######################################################################

# Path to nodemcu-uploader (https://github.com/kmpm/nodemcu-uploader)
NODEMCU-UPLOADER?=python ../nodemcu-uploader/nodemcu-uploader.py

# Path to LUA cross compiler (part of the nodemcu firmware; only needed to compile the LFS image yourself)
LUACC?=../nodemcu-firmware/luac.cross

# Serial port
PORT?=$(shell ls /dev/cu.SLAB_USBtoUART /dev/ttyUSB* 2>/dev/null|head -n1)
SPEED?=115200

define _upload
@$(NODEMCU-UPLOADER) -b $(SPEED) --start_baud $(SPEED) -p $(PORT) upload $^
endef

GZFLAGS?=--best
%.gz: %
	gzip $(GZFLAGS) <$< >$@

######################################################################

LFS_IMAGE ?= lfs.img
HTTP_FILES := $(wildcard http/*) \
   $(patsubst %,%.gz,$(wildcard http/*.html http/*.css http/*.js))
WIFI_CONFIG := $(wildcard *conf*.lua)
LFS_FILES := $(LFS_IMAGE)  $(wildcard *.lua)
FILE ?=

# Print usage
usage:
	@echo "make upload FILE:=<file>  to upload a specific file (i.e make upload FILE:=init.lua)"
	@echo "make upload_http          to upload files to be served"
	@echo "make upload_server        to upload the server code and init.lua"
	@echo "make upload_all           to upload all"

# Upload one file only
upload: $(FILE)
	$(_upload)

# build filemanager
FM_ZIPFILES := filemanager/fm.html filemanager/fm.js filemanager/fm.css
FM_FILES := filemanager/fm.lua
fm: $(FM_FILES) $(FM_ZIPFILES)
	for f in $(FM_FILES); do cp $$f http`echo $$f |sed -e 's/^filemanager//'`; done
	for f in $(FM_ZIPFILES); do gzip -9 <$$f  >http`echo $$f |sed -e 's/^filemanager//'`.gz; done

# Upload HTTP files only
upload_http: $(HTTP_FILES) fm
	$(_upload)

# Upload wifi configuration
upload_wifi_config: $(WIFI_CONFIG)
	$(_upload)

# Upload lfs image and init files
upload_lfs: upload_server

upload_server: $(LFS_FILES)
	$(_upload)

# build LFS image using luac.cross from nodemcu-firmware
# if you don't have a local build environment, you can use the build service, instead
$(LFS_IMAGE): srv/*.lua
	$(LUACC) -f -o $(LFS_IMAGE) srv/*.lua

# Upload all files
upload_all: $(HTTP_FILES) $(LFS_FILES) $(WIFI_CONFIG)
	$(_upload)

.ENTRY: usage
.PHONY: usage upload_http upload_server upload_wifi_config \
upload_lfs upload_all upload_all_lfs fm
