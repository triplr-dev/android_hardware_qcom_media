ifneq ($(BUILD_TINY_ANDROID),true)

ROOT_DIR := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_PATH:= $(ROOT_DIR)

# ---------------------------------------------------------------------------------
# 				Common definitons
# ---------------------------------------------------------------------------------

libmm-venc-def := -g -O3 -Dlrintf=_ffix_r
libmm-venc-def += -D__align=__alignx
libmm-venc-def += -D__alignx\(x\)=__attribute__\(\(__aligned__\(x\)\)\)
libmm-venc-def += -DT_ARM
libmm-venc-def += -Dinline=__inline
libmm-venc-def += -D_ANDROID_
libmm-venc-def += -UENABLE_DEBUG_LOW
libmm-venc-def += -DENABLE_DEBUG_HIGH
libmm-venc-def += -DENABLE_DEBUG_ERROR
libmm-venc-def += -UINPUT_BUFFER_LOG
libmm-venc-def += -UOUTPUT_BUFFER_LOG
libmm-venc-def += -USINGLE_ENCODER_INSTANCE
ifeq ($(TARGET_BOARD_PLATFORM),msm8660)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -UENABLE_GET_SYNTAX_HDR
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8960)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -DMAX_RES_1080P_EBI
libmm-venc-def += -UENABLE_GET_SYNTAX_HDR
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8974)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -DMAX_RES_1080P_EBI
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
libmm-venc-def += -D_MSM8974_
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm7627a)
libmm-venc-def += -DMAX_RES_720P
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm7630_surf)
libmm-venc-def += -DMAX_RES_720P
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8610)
libmm-venc-def += -DMAX_RES_720P
libmm-venc-def += -D_MSM8974_
endif
ifeq ($(TARGET_BOARD_PLATFORM),msm8226)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -D_MSM8974_
libmm-venc-def += -D_MSM8226_
endif
ifeq ($(TARGET_BOARD_PLATFORM),apq8084)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -DMAX_RES_1080P_EBI
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
libmm-venc-def += -D_MSM8974_
endif
ifeq ($(TARGET_BOARD_PLATFORM),mpq8092)
libmm-venc-def += -DMAX_RES_1080P
libmm-venc-def += -DMAX_RES_1080P_EBI
libOmxVdec-def += -DPROCESS_EXTRADATA_IN_OUTPUT_PORT
libmm-venc-def += -D_MSM8974_
endif

ifeq ($(TARGET_USES_ION),true)
libmm-venc-def += -DUSE_ION
endif

libmm-venc-def += -D_ANDROID_ICS_
# ---------------------------------------------------------------------------------
# 			Make the Shared library (libOmxVenc)
# ---------------------------------------------------------------------------------

include $(CLEAR_VARS)

ifneq ($(TARGET_QCOM_DISPLAY_VARIANT),)
DISPLAY := display-$(TARGET_QCOM_DISPLAY_VARIANT)
else
DISPLAY := display/$(TARGET_BOARD_PLATFORM)
# Fix the header inclusions for platform variants without an explicit path
ifneq ($(filter msm8610 apq8084 mpq8092,$(TARGET_BOARD_PLATFORM)),)
  DISPLAY := display/msm8974
endif
endif

libmm-venc-inc      := bionic/libc/include
libmm-venc-inc      += bionic/libstdc++/include
libmm-venc-inc      += $(LOCAL_PATH)/venc/inc
libmm-venc-inc      += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
libmm-venc-inc      += $(OMX_VIDEO_PATH)/vidc/common/inc
libmm-venc-inc      += hardware/qcom/media/mm-core/inc
libmm-venc-inc      += hardware/qcom/media/libstagefrighthw
libmm-venc-inc      += hardware/qcom/$(DISPLAY)/libgralloc
libmm-venc-inc      += frameworks/native/include/media/hardware
libmm-venc-inc      += frameworks/native/include/media/openmax
libmm-venc-inc      += hardware/qcom/media/libc2dcolorconvert
libmm-venc-inc      += hardware/qcom/$(DISPLAY)/libcopybit
libmm-venc-inc      += frameworks/av/include/media/stagefright
libmm-venc-inc      += frameworks/av/include/media/hardware
libmm-venc-inc      += $(venc-inc)

LOCAL_MODULE                    := libOmxVenc
LOCAL_MODULE_TAGS               := optional
LOCAL_CFLAGS                    := $(libmm-venc-def)
LOCAL_C_INCLUDES                := $(libmm-venc-inc)

LOCAL_PRELINK_MODULE      := false
LOCAL_SHARED_LIBRARIES    := liblog libutils libbinder libcutils \
                             libc2dcolorconvert libdl

LOCAL_SRC_FILES   := venc/src/omx_video_base.cpp
LOCAL_SRC_FILES   += venc/src/omx_video_encoder.cpp
ifneq ($(filter msm8974 msm8610 msm8226 apq8084 mpq8092,$(TARGET_BOARD_PLATFORM)),)
LOCAL_SRC_FILES   += venc/src/video_encoder_device_v4l2.cpp
else
LOCAL_SRC_FILES   += venc/src/video_encoder_device.cpp
endif

LOCAL_SRC_FILES   += common/src/extra_data_handler.cpp

include $(BUILD_SHARED_LIBRARY)

# -----------------------------------------------------------------------------
#  #                       Make the apps-test (mm-venc-omx-test720p)
# -----------------------------------------------------------------------------

include $(CLEAR_VARS)

mm-venc-test720p-inc            := $(TARGET_OUT_HEADERS)/mm-core
mm-venc-test720p-inc            += $(LOCAL_PATH)/venc/inc
mm-venc-test720p-inc            += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
mm-venc-test720p-inc            += $(OMX_VIDEO_PATH)/vidc/common/inc
mm-venc-test720p-inc            += hardware/qcom/media/mm-core/inc
mm-venc-test720p-inc            += hardware/qcom/$(DISPLAY)/libgralloc
mm-venc-test720p-inc            += $(venc-inc)

LOCAL_MODULE                    := mm-venc-omx-test720p
LOCAL_MODULE_TAGS               := optional
LOCAL_CFLAGS                    := $(libmm-venc-def)
LOCAL_C_INCLUDES                := $(mm-venc-test720p-inc)
LOCAL_ADDITIONAL_DEPENDENCIES   := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
LOCAL_PRELINK_MODULE            := false
LOCAL_SHARED_LIBRARIES          := libmm-omxcore libOmxVenc libbinder liblog

LOCAL_SRC_FILES                 := venc/test/venc_test.cpp
LOCAL_SRC_FILES                 += venc/test/camera_test.cpp
LOCAL_SRC_FILES                 += venc/test/venc_util.c
LOCAL_SRC_FILES                 += venc/test/fb_test.c

include $(BUILD_EXECUTABLE)

# -----------------------------------------------------------------------------
# 			Make the apps-test (mm-video-driver-test)
# -----------------------------------------------------------------------------

include $(CLEAR_VARS)

venc-test-inc                   += $(LOCAL_PATH)/venc/inc
venc-test-inc                   += hardware/qcom/$(DISPLAY)/libgralloc
venc-test-inc                   += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
venc-test-inc                   += $(venc-inc)

LOCAL_MODULE                    := mm-video-encdrv-test
LOCAL_MODULE_TAGS               := optional
LOCAL_C_INCLUDES                := $(venc-test-inc)
LOCAL_C_INCLUDES                += hardware/qcom/media/mm-core/inc
LOCAL_ADDITIONAL_DEPENDENCIES   := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
LOCAL_PRELINK_MODULE            := false

LOCAL_SRC_FILES                 := venc/test/video_encoder_test.c
LOCAL_SRC_FILES                 += venc/test/queue.c

include $(BUILD_EXECUTABLE)

endif #BUILD_TINY_ANDROID

# ---------------------------------------------------------------------------------
# 					END
# ---------------------------------------------------------------------------------