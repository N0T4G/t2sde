define(`PPC', 'PowerPC')dnl

dnl System type (default=Macintosh)
dnl
CONFIG_PPC=y
CONFIG_6xx=y
# CONFIG_4xx is not set
# CONFIG_PPC64 is not set
# CONFIG_82xx is not set
# CONFIG_8xx is not set
CONFIG_PMAC=y
# CONFIG_PREP is not set
# CONFIG_CHRP is not set
# CONFIG_ALL_PPC is not set
# CONFIG_GEMINI is not set
# CONFIG_APUS is not set
# CONFIG_SMP is not set
# CONFIG_ALTIVEC is not set
CONFIG_MACH_SPECIFIC=y

# additional 2.6 kernel configs
CONFIG_PPC32=y
# CONFIG_40x is not set
# CONFIG_POWER3 is not set


include(`kernel-common.conf')
include(`kernel-scsi.conf')
include(`kernel-net.conf')
include(`kernel-fs.conf')

dnl macs need a special RTC ... (this need to be fixed in the kernel so we
dnl can have generic support for the rs6k and mac support at the same time
dnl
# CONFIG_GEN_RTC is not set
CONFIG_PPC_RTC=m
# CONFIG_RTC is not set

dnl macs need an FB
dnl
CONFIG_FB_RIVA=y
CONFIG_FB_MATROX=m
CONFIG_FB_ATY=y
CONFIG_FB_RADEON=y

dnl AGP
dnl
CONFIG_AGP=y
CONFIG_AGP_UNINORTH=m

dnl power management
dnl
CONFIG_PMAC_PBOOK=y
CONFIG_PMAC_BACKLIGHT=y
CONFIG_PMAC_APM_EMU=y

# for 2.6 kernels
dnl
CONFIG_TAU=y

CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_PMAC=y
CONFIG_CPU_FREQ_26_API=y

CONFIG_MAC_FLOPPY=y
CONFIG_PMU_HD_BLINK=y
# CONFIG_MAC_ADBKEYCODES is not set

dnl make sure old OSS modules are build (ALSA does not yet work correct)
dnl
CONFIG_DMASOUND_PMAC=m
CONFIG_DMASOUND=m

dnl some network teaks (the GMAC is obsoleted by SUNGEM)
dnl
# CONFIG_GMAC is not set
CONFIG_SUNGEM=y

