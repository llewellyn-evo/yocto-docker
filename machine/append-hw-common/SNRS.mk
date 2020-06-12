include machine/append-sw-common/qemu-target.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private

LOCAL_CONF_OPT += 'INHERIT += " userconfig"'

LOCAL_CONF_OPT += 'IMAGE_ROOTFS_EXTRA_SPACE = "50000"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " SNRS-$${EVOSN} SNRS-$${EVOSN}-etc SNRS-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "snrs-$${EVOSN}"'

LOCAL_CONF_OPT += 'BRIDGE_ADDRESS="192.168.$${EVOSN}.2"'

LOCAL_CONF_OPT += 'BRIDGE_GATEWAY="192.168.$${EVOSN}.1"'