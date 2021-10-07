include machine/mx6ul-comm-module/default.mk
include machine/append-hw-common/sonobot-basestation-comm.mk
include machine/append-sw-common/swupdate.mk

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'

LOCAL_CONF_OPT += 'BRIDGE_ADDRESS="172.16.72.31/16"'

LOCAL_CONF_OPT += 'BRIDGE_GATEWAY="172.16.72.30"'

LOCAL_CONF_OPT += 'EVOSN = "5042"'