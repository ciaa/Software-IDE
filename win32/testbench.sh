###############################################################################
#
# Copyright 2014, ACSE & CADIEEL
#    ACSE   : http://www.sase.com.ar/asociacion-civil-sistemas-embebidos/ciaa/
#    CADIEEL: http://www.cadieel.org.ar
#
# This file is part of CIAA Firmware.
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
GCC_VERSION=4.8.3
CROSS_GCC_VERSION=4.8.4
PERL_VERSION=5.14.2
GIT_VERSION=2.1.1
PHP_VERSION=5.5.16
RUBY_VERSION=2.0.0
MAKE_VERSION=4.0
OOCD_VERSION=0.8.0

FIRMWARE_REPO="git://github.com/ciaa/Firmware.git"
FIRMWARE_VERSION="0.2.0"

cd /tmp

function check_home {
echo -n "Check $HOME location... "
if [ $(cygpath -w $HOME|grep -c -P -e "[A-Z]\\:\\\\Users\\\\"$USER) -eq 1 ]; then
	echo "PASS"
	return 0
else
	echo "FAIL"
	echo $(cygpath -w $HOME) > cygwin-home.log
	return 1
fi
}

function check_ver {
echo -n "Checking $1 version... "
if [ $( $2 2>&1 | grep -F -c -e "$3" ) -eq 1 ]; then
	echo "PASS"
	return 0
else
	echo "ERROR!!!"
	sh -c "$2" &> "check_$1.log"
	return 1
fi
}

function cleanup {
	rm -fR Firmware
}

function do_configure {
	/bin/cat <<EOM > Firmware/Makefile.mine
#ARCH           = cortexM4
#CPUTYPE        = lpc43xx
#CPU            = lpc4337
#COMPILER       = gcc
BOARD          ?= ciaa_sim_ia32
PROJECT_PATH ?= examples/blinking
EOM
}

function check_clone {
echo -n "Checking clone $1 tag $2... "
git clone -b $2 $1 Firmware &> git-clone.log
if [ $? -eq 0 ]; then
	echo "PASS"
	do_configure Firmware
	return 0
else
	echo "ERROR!!!"
	cleanup
	return 1
fi
}

function check_make {
echo -n "Checking make $1 over $2... "
make -C $2 $1 &> make.log
if [ $? -eq 0 ]; then
	echo "PASS"
	return 0
else
	echo "ERROR!!!"
	cleanup
	return 1
fi
} 	

check_home
check_ver "gcc" "gcc --version" "$GCC_VERSION" &&
check_ver "cross gcc" "arm-none-eabi-gcc --version" "$CROSS_GCC_VERSION" &&
check_ver "Perl" "perl --version" "(v$PERL_VERSION" &&
check_ver "Git" "git --version" "git version $GIT_VERSION" &&
check_ver "PHP" "php --version" "PHP $PHP_VERSION" &&
check_ver "Ruby" "ruby --version" "ruby $RUBY_VERSION" &&
check_ver "Make" "make --version" "GNU Make $MAKE_VERSION" &&
check_ver "openocd" "openocd --version" "Open On-Chip Debugger $OOCD_VERSION" &&
check_clone $FIRMWARE_REPO $FIRMWARE_VERSION &&
check_make generate Firmware &&
check_make "" Firmware &&
echo "ALL PASS, cleaning..."
cleanup
