include machine/mx6-evobb-common/default.mk
include machine/append-hw-common/sonobot-payload.mk

#include machine/append-sw-common/qemu-target.mk
include machine/append-sw-common/hyscan.mk
include machine/append-sw-common/dune.mk

LOCAL_CONF_OPT += 'EVOSN = "21"'

