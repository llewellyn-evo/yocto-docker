# Configure i386 for qemu-target, add package to rootfs
LOCAL_CONF_OPT += 'QEMU_TARGETS_class-target = "i386"' \
                  'CORE_IMAGE_EXTRA_INSTALL += "qemu"'
