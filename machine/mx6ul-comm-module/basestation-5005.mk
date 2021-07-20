include machine/mx6ul-comm-module/default.mk
include machine/append-hw-common/basestation-comm.mk

LOCAL_CONF_OPT += 'BRIDGE_ADDRESS="172.16.35.31/16"'

LOCAL_CONF_OPT += 'BRIDGE_GATEWAY="172.16.35.30"'

LOCAL_CONF_OPT += 'EVOSN = "5"'