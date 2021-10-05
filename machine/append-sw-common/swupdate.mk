include machine/append-sw-common/qemu-target.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private

#Install SWUPDATE
LOCAL_CONF_OPT    += 'IMAGE_INSTALL_append = " swupdate swupdate-www"'
LOCAL_CONF_OPT 	  += 'PREFERRED_VERSION_swupdate = "2021.04"'
