#!/bin/bash
set -x

NPX=1; NPY=1
if [ "${METROMS_MYHOST}" == "metlocal" ]; then
    NPX=1  
    NPY=2
elif [ "${METROMS_MYHOST}" == "vilje" ]; then
    NPX=1  
    NPY=2
fi

if [ $# -ge 2 ]; then
    NPX=$1
    NPY=$2
fi

echo "NPX = $NPX, NPY = $NPY"

#if [ $# -ne 2 ]
#then
#    echo "Usage: $0 NPX NPY"
#    exit 1
#fi 

export workingdir=${PWD} 
cd ../
metroms_base=${PWD} 
cd ../
if [ "$METROMS_TMPDIR" == "" ]; then
    tup=${PWD}
else
    tup=${METROMS_TMPDIR}
    if [ ! -d $tup ] ; then
	echo "$tup not defined, set environment variable METROMS_TMPDIR to "
	echo "override default behaviour"
	exit 
    fi
fi

# Build CICE
mkdir -p ${tup}/tmproms
cd ${tup}/tmproms
# Unpack standard source files
tar -xf ${metroms_base}/static_libs/cice5.tar.gz
export CICE_DIR=${tup}/tmproms/cice
cd $CICE_DIR

export MCT_INCDIR=${tup}/tmproms/MCT/include
export MCT_LIBDIR=${tup}/tmproms/MCT/lib


# Copy modified source files
cp -auv $workingdir/common/modified_src/cice ${tup}/tmproms

# Remove old binaries
rm -f $CICE_DIR/rundir/cice

rm -rf ${tup}/tmproms/cice/rundir/compile

#
# NB! Compile flags needed on Vilje
# -O2 -w -convert big_endian -assume byterecl
#

./comp_ice $NPX $NPY

# Test if compilation and linking was successfull

if [ ! -f $CICE_DIR/rundir/cice ]; then
    echo "$CICE_DIR/rundir/cice not found"
    echo "Error with compilation "
    exit -1
fi

# Build a library (for use in the ROMS build)
cd $CICE_DIR/rundir/compile
ar rcv libcice.a *.o

rm -f $CICE_DIR/rundir/cice

#cd $CICE_DIR

#if [ -d $CICE_DIR/data/atm/A20/ecmwf ]; then
#    echo ls $CICE_DIR/data/atm/A20/ecmwf
#    ls $CICE_DIR/data/atm/A20/ecmwf
#else
#    echo "Directory for atmosphere forcing data should be linked to"
#    echo $CICE_DIR/data/atm/RES/ATM_DATA_TYPE
#    echo "where RES is model setup (A20,??)"
#    echo "and ATM_DATA_TYPE is dataset used (ecmwf/ncar ..)"
#    echo $CICE_DIR/data/atm/A20/ecmwf not found
#    exit
#fi

set +x
