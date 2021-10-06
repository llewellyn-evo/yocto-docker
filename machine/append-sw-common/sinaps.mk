# Erlang OTP21
LOCAL_CONF_OPT += 'PREFERRED_VERSION_erlang = "21.1%"'
LOCAL_CONF_OPT += 'PREFERRED_VERSION_erlang-native = "21.1%"'

# SiNAPS lives in meta-evo-private
LAYERS += $(SOURCES_DIR)/meta-evo-private

# Install necessary packages.
LOCAL_CONF_OPT += 'CORE_IMAGE_EXTRA_INSTALL += "sinaps pure-ftpd"'
