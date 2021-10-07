include machine/mx6ul-comm-module/default.mk
include machine/append-sw-common/swupdate.mk
include machine/append-hw-common/usbl-buoy-comm.mk

LOCAL_CONF_OPT += 'PREFERRED_VERSION_sinaps = "2.3"'

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'

LOCAL_CONF_OPT += 'EVOSN = "4"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = " gpspps"'