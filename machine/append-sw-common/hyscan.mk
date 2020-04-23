# HyScan layer.
LAYERS += $(SOURCES_DIR)/meta-hyscan

# Install necessary packages.
LOCAL_CONF_OPT += 'CORE_IMAGE_EXTRA_INSTALL += "hyscansonarproxyd hyscanhydra4drv hyscannmeadrv "'
