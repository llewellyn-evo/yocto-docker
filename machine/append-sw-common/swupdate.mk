LAYERS += git@gitlab.evologics.de:bsp/meta-evo-private.git

#Install SWUPDATE
LOCAL_CONF_OPT    += 'IMAGE_INSTALL_append = " swupdate swupdate-www"'
LOCAL_CONF_OPT 	  += 'PREFERRED_VERSION_swupdate = "2021.04"'
