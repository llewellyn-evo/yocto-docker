include machine/append-sw-common/qemu-target.mk

LAYERS += $(SOURCES_DIR)/meta-evo-private
LOCAL_CONF_OPT += 'MACHINEOVERRIDES =. "navimum-swom:navimum-swom-$${EVOSN}:"' \
                  'CORE_IMAGE_EXTRA_INSTALL += "dune-navimum-swom-$${EVOSN} dune-etc-navimum-swom-$${EVOSN} dune-etc-common dune-etc-wmm"' \
				  'hostname_pn-base-files = "navimum-swom-$${EVOSN}"'
