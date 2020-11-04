include machine/append-sw-common/qemu-target.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private

LOCAL_CONF_OPT += 'INHERIT += " userconfig"'

LOCAL_CONF_OPT += 'IMAGE_ROOTFS_EXTRA_SPACE = "50000"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_remove = " gpsd-tiny chrony"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "qlbl-deck-comm-$${EVOSN}"'