include machine/mx6ul-comm-module/default.mk
include machine/append-sw-common/update.mk
include machine/append-hw-common/fast-penguin.mk

LOCAL_CONF_OPT += 'EVOSN = "2"'

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = " atmclkpps"'