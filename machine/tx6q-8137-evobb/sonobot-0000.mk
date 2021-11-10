# Board defaults
include machine/tx6q-8137-evobb/default.mk

# Vehicle common defs
include machine/append-hw-common/sonobot-r5.mk

# Software common defs
include machine/append-sw-common/qemu-target.mk
include machine/append-sw-common/hyscan.mk
include machine/append-sw-common/dune.mk
include machine/append-sw-common/evotools.mk
include machine/append-sw-common/swupdate.mk

# Vehicle number
LOCAL_CONF_OPT += 'EVOSN = "0000"'
