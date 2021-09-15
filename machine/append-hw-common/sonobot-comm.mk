include machine/append-sw-common/qemu-target.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-sonobot-comm-$${EVOSN} dune-sonobot-comm-$${EVOSN}-etc dune-sonobot-comm-$${EVOSN}-default"'

LOCAL_CONF_OPT += 'hostname_pn-base-files = "sonobot-$${EVOSN}-comm"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = "can"'
