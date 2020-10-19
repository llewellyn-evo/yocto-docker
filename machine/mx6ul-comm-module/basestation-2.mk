include machine/mx6ul-comm-module/default.mk
include machine/append-hw-common/basestation-comm.mk

LOCAL_CONF_OPT += 'BRIDGE_ADDRESS="172.16.20.4"'

LOCAL_CONF_OPT += 'BRIDGE_GATEWAY="172.16.20.3"'

LOCAL_CONF_OPT += 'EVOSN = "2"'