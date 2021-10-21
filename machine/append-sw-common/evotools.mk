# evotools come from meta-evo-private
LAYERS += $(SOURCES_DIR)/meta-evo-private

# Install necessary packages.
LOCAL_CONF_OPT += 'CORE_IMAGE_EXTRA_INSTALL += "c2k-esc-serial libevocanopen"'
