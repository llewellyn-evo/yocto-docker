include machine/mx6ul-comm-module/default.mk
include machine/append-hw-common/sonobot-comm.mk
include machine/append-sw-common/swupdate.mk

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'

LOCAL_CONF_OPT += 'EVOSN = "5037"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = " gpspps"'