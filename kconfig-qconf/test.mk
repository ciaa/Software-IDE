
menuconfig:
	@mkdir -p include/generated include/config
	@kconfig-qconf Kconfig.test

mrproper:
	@rm -fR include .config .config.old
