#!/bin/bash
#
# Copyright 2016, International Business Machines
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################
NAME=`basename $2`
if [ "$NAME" == "top.sh" ]; then
  echo "patch $NAME for $SIMULATOR"
  if [ "$SIMULATOR" == "xsim" ]; then
    echo "xsim disable step=simulate"
    sed -i "s/  simulate/# simulate/g"                   $1/$2 # run up to elaboration, skip execution
    echo "xsim add -svlib libdpi"
    sed -i "s/-log elaborate.log/-log elaborate.log -sv_lib libdpi -sv_root ./g" $1/$2
  fi
  if [ "$SIMULATOR" == "irun" ]; then
    echo "irun run up to elaboration"
    sed -i "s/93 -relax/93 -elaborate -relax/gI"         $1/$2 # run irun up to elaboration, skip execution
    echo "irun build top in work library"
    sed -i "s/-top xil_defaultlib.top/-top work.top/gI"  $1/$2 # build top in work library
    if [ -n $DENALI ];then :
      echo "irun include denali files"
      perl -i.ori -pe 'use Env qw(DENALI);s/(glbl.v)/$1 \\\n       +incdir+"${DENALI}\/ddvapi\/verilog"/mg' $1/$2 # add denali include directory
    fi
    if [ -f ${DONUT_HARDWARE_ROOT}/sim/ies/run.f ]; then
#     echo "irun compile top.v with system verilog"            # not needed anymore, since we work now with top.sv
#     perl -i.ori -pe 's/(.*\/verilog\/top.v)/ -sv $1/mg' ${DONUT_HARDWARE_ROOT}/sim/ies/run.f;                          # compile top.v with system verilog
      echo "irun remove second glbl.v from compile list"
      perl -i.ori -pe 'BEGIN{undef $/;} s/(^-makelib.*\n.*glbl.v.*\n.*endlib)//mg' ${DONUT_HARDWARE_ROOT}/sim/ies/run.f; # remove glbl.v from compile list
    fi
  fi
  if [ "$SIMULATOR" == "ncsim" ]; then
    echo "ncsim disable step=simulate"
    sed -i "s/  simulate/# simulate/g"                   $1/$2 # run ncsim up to elaboration, skip execution
    echo "ncsim stop on first compile error"
    sed -i "s/opts_ver=/set -e\nopts_ver=/g"             $1/$2 # use set -e to stop compilation on first error
  fi
  if [ "$SIMULATOR" == "questa" ]; then
    echo "questa disable step=simulate"
    sed -i "s/  simulate/# simulate/g"                   $1/$2 # run up to elaboration, skip execution
  fi
fi