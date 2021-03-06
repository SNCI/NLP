####  Change CUDA_PATH and -gencode options in CFLAGS1 if necessary. 

BIN_NAME1 = conText
BIN_DIR = bin
TARGET1 = $(BIN_DIR)/$(BIN_NAME1)

CUDA_PATH       = /usr/local/cuda
CUDA_INC_PATH   = $(CUDA_PATH)/include
CUDA_BIN_PATH   = $(CUDA_PATH)/bin
CUDA_LIB_PATH   = $(CUDA_PATH)/lib64

# modified by Chang, this flags need to be added of cudart, cublas,
# these are the libs according to your installation of CUDA
# To make it work well, add the correct lib names with corresponding version
LDFLAGS1   = -L$(CUDA_LIB_PATH) -lcudart -lcublas -lcurand -lcusparse

# modified by Chang, this needs to be chanaged according to your network structure
# In K40 Telsa, we should use the compute_52, sm_52
# otherwise it compiles well, but when running shell script it faile with "Get NULL String Cuda::getErrorString"
# inclues, that's a strange error because of the CUDA installation.
CFLAGS1 = -Isrc/com -Isrc/data -Isrc/cnet  -D__AZ_SMAT_SINGLE__ -D__AZ_GPU__  -I$(CUDA_INC_PATH) -O2 \
                -gencode arch=compute_52,code=sm_52

CPP_FILES1= 	\
	src/com/AzDmat.cpp \
	src/com/AzParam.cpp \
	src/com/AzSmat.cpp \
	src/com/AzStrPool.cpp \
	src/com/AzTextMat.cpp \
	src/com/AzTools.cpp \
	src/com/AzUtil.cpp \
	src/cnet/AzpPatchDflt.cpp \
	src/cnet/AzpCNet3.cpp \
	src/cnet/AzpLayer.cpp \
	src/cnet/AzpMain_conText.cpp \
	src/cnet/AzpLmSgd.cpp \
	src/cnet/AzPmat.cpp \
	src/cnet/AzPmatSpa.cpp \
	src/cnet/AzPmatApp.cpp \
	src/cnet/AzPmat_gpu.cu \
	src/cnet/AzPmatSpa_gpu.cu \
	src/cnet/AzCuda_Pmat.cu \
	src/cnet/AzCuda_PmatSpa.cu \
	src/cnet/AzCuda_PmatApp.cu \
	src/cnet/AzpEv.cpp \
	src/cnet/AzpLossDflt.cpp \
	src/cnet/driv_conText.cpp \
	src/cnet/AzpCNet3_multi.cpp \
	src/cnet/AzpCNet3_multi_side.cpp \
	src/cnet/AzpLayerConn.cpp


BIN_NAME2 = prepText
TARGET2 = $(BIN_DIR)/$(BIN_NAME2)
CFLAGS2 = -Isrc/com -O2 -D__AZ_SMAT_SINGLE__

CPP_FILES2= 	\
	src/com/AzDmat.cpp \
	src/com/AzParam.cpp \
	src/com/AzSmat.cpp \
	src/com/AzStrPool.cpp \
	src/com/AzTools.cpp \
	src/com/AzTextMat.cpp \
	src/com/AzUtil.cpp \
	src/data/AzPrepText.cpp \
	src/data/AzPrepText2.cpp \
	src/data/AzTools_text.cpp \
	src/data/driv_PrepText2.cpp

# add by Chang, for third parallel way of prepText, conText
BIN_NAME3 = myText
TARGET3 = $(BIN_DIR)/$(BIN_NAME3)
CFLAGS3 = -Isrc/com -O2 -D__AZ_SMAT_SINGLE__

CPP_FILES3= 	\
	src/com/AzDmat.cpp \
	src/com/AzParam.cpp \
	src/com/AzSmat.cpp \
	src/com/AzStrPool.cpp \
	src/com/AzTools.cpp \
	src/com/AzTextMat.cpp \
	src/com/AzUtil.cpp \
	src/data/AzPrepText.cpp \
	src/data/AzTools_text.cpp \
	src/cnet/AzpCNet3_multi.cpp \
	src/cnet/AzpCNet3_multi_side.cpp \

all: $(TARGET1) $(TARGET2) $(TARGET3)

${TARGET1}: 
	/bin/rm -f $(TARGET1)
	$(CUDA_BIN_PATH)/nvcc $(CPP_FILES1) $(CFLAGS1) -o $(TARGET1) $(LDFLAGS1)

${TARGET2}:
	/bin/rm -f $(TARGET2)
	g++ -g $(CPP_FILES2) $(CFLAGS2) -o $(TARGET2)

# add myText for generating the preprocessing tokens and conText for training/testing
${TARGET3}:
	/bin/rm -f $(TARGET3)
	g++ -g $(CPP_FILES3) $(CFLAGS3) -o $(TARGET3)

clean: 
	/bin/rm -f $(TARGET1)
	/bin/rm -f $(TARGET2)
	/bin/rm -f $(TARGET3) # remember to free then
