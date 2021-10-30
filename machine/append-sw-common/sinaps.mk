# Erlang OTP21
LOCAL_CONF_OPT += 'PREFERRED_VERSION_erlang = "21.1%"'
LOCAL_CONF_OPT += 'PREFERRED_VERSION_erlang-native = "21.1%"'
LOCAL_CONF_OPT += 'PACKAGECONFIG_pn-nodejs-native = "ares brotli zlib"'

# SiNAPS lives in meta-evo-private
LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

# Install necessary packages.
LOCAL_CONF_OPT += 'CORE_IMAGE_EXTRA_INSTALL += "sinaps pure-ftpd"'
