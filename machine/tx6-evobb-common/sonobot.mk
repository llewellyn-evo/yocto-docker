include machine/tx6-evobb-common/qemu-target.mk
include machine/tx6-evobb-common/hyscan.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private
LOCAL_CONF_OPT += 'MACHINEOVERRIDES =. "sonobot:sonobot-$${EVOSN}:"' \
                  'CORE_IMAGE_EXTRA_INSTALL += "dune-sonobot-$${EVOSN} dune-etc-sonobot-$${EVOSN} dune-etc-common dune-etc-wmm"' \
                  'hostname_pn-base-files = "sonobot-$${EVOSN}"'
