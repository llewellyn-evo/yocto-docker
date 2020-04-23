# Board defaults
include machine/colibri-imx6-iris-evo/default.mk

# Vehicle common defs
include machine/append-hw-common/sonobot-payload.mk

# Software common defs
#include machine/append-sw-common/qemu-target.mk
include machine/append-sw-common/hyscan.mk
include machine/append-sw-common/dune.mk

# Vehicle number
LOCAL_CONF_OPT += 'EVOSN = "21"'
