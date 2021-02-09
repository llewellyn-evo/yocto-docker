# Board defaults
include machine/mx6-evobb-common/default.mk

# Vehicle common defs
include machine/append-hw-common/qlbl-deck.mk

# Software common defs
#include machine/append-sw-common/qemu-target.mk
#include machine/append-sw-common/hyscan.mk
#include machine/append-sw-common/dune.mk
include machine/append-sw-common/sinaps.mk

# Vehicle number
LOCAL_CONF_OPT += 'EVOSN = "2"'
