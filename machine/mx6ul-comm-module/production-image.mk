include machine/mx6ul-comm-module/default.mk
include machine/append-sw-common/update.mk

LOCAL_CONF_OPT += 'hostname_pn-base-files = "production-comm-image"'

LOCAL_CONF_OPT += 'IMAGE_CONFIGS = " can enablesw"'

LOCAL_CONF_OPT += 'IMAGE_INSTALL_append = " dune-production-comm dune-production-comm-etc dune-production-comm-default"'

LOCAL_CONF_OPT += 'HW_REVISION = "2.0"'
