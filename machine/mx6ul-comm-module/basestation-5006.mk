include machine/mx6ul-comm-module/default.mk
include machine/append-hw-common/basestation-comm.mk
include machine/append-sw-common/swupdate.mk

LOCAL_CONF_OPT += 'BRIDGE_ADDRESS="172.16.36.31/16"'

LOCAL_CONF_OPT += 'BRIDGE_GATEWAY="172.16.36.30"'

LOCAL_CONF_OPT += 'EVOSN = "5006"'

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " htop soft-hwclock"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS_append = " enablesw"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-basestation-$${EVOSN} dune-basestation-$${EVOSN}-etc dune-basestation-$${EVOSN}-default"'