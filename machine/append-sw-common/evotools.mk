# evotools come from meta-evo-private
LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

# Install necessary packages.
LOCAL_CONF_OPT += 'CORE_IMAGE_EXTRA_INSTALL += "c2k-esc-serial libevocanopen"'
