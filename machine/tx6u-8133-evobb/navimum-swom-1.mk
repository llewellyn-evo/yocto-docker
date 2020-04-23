# Board defaults
include machine/tx6u-8133-evobb/default.mk

# Vehicle common defs
include machine/append-hw-common/navimum-swom.mk

# Software common defs
#include machine/append-sw-common/qemu-target.mk
#include machine/append-sw-common/hyscan.mk
include machine/append-sw-common/dune.mk

# Vehicle number
LOCAL_CONF_OPT += 'EVOSN = "1"'
