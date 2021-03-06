#
# Copyright 2016, 2017 International Business Machines
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

include ../config.mk

DESTDIR ?= /usr
libs = ../lib/libsnap.a
LDLIBS += $(libs) -lpthread

# Link statically for PSLSE simulation and dynamically for real version
ifdef BUILD_SIMCODE
libs += $(PSLSE_ROOT)/libcxl/libcxl.a
CFLAGS+=-D_SIM_
else
LDLIBS += -lcxl
endif

snap_peek_objs = force_cpu.o
snap_poke_objs = force_cpu.o

projs = snap_peek snap_poke bfs_diff
projs += snap_maint snap_nvme_init
objs = force_cpu.o $(projs:=.o)
hfiles = force_cpu.h  snap_fw_example.h

all: $(projs)

$(projs): $(objs) $(libs)

### Deactivate existing implicit rule
%: %.c
%: %.sh

### Generic rule to build a tool
%: %.o
	$(CC) $(LDFLAGS) $@.o $($(@)_objs) $($(@)_libs) $(LDLIBS) -o $@

%.o: %.c $(libs) $(hfiles)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

install: all
	@mkdir -p $(DESTDIR)/bin
	install -D -m 755 snap_peek -T $(DESTDIR)/bin/snap_peek
	install -D -m 755 snap_poke -T $(DESTDIR)/bin/snap_poke

uninstall:
	@for f in $(projs) ; do					\
		echo "removing $(DESTDIR)/bin/$$f ...";		\
		$(RM) $(DESTDIR)/bin/$$f;			\
	done

clean distclean:
	@$(RM) $(objs) $(projs)
