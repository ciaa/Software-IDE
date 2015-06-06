###############################################################################
#
# Copyright 2015, Juan Cecconi
# Copyright 2015, Martin Ribelotta
#
# This file is part of CIAA IDE.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
###############################################################################

#/bin/sh

FIRMWARE_REPO="https://github.com/ciaa/Firmware.git"
FIRMWARE_VERSION="0.5.0"

function cleanup {
   echo "cleanup done!"
}

function do_configure {
	cp Firmware/Makefile.config Firmware/Makefile.mine
#   sed -i 's/BOARD          ?= ciaa_sim_ia32/BOARD          ?= edu_ciaa_nxp/g' Makefile.mine
}

function do_clone {
echo -n "Cloning Firmware repo $1 ..."
git clone --recursive $1 Firmware
if [ $? -eq 0 ]; then
   echo -n "New branch based on Firmware tag $2 named tag_$2 ..."
   git checkout -b tag_$2 $2
	do_configure Firmware
	return 0
else
	echo "ERROR!!!"
	cleanup
	return 1
fi
}

cd `cygpath -u "$CIAA_SUITE_PATH"`
do_clone $FIRMWARE_REPO $FIRMWARE_VERSION
