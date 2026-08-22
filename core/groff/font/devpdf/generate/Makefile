# Copyright 2025 G. Branden Robinson
#
# This file is part of groff, the GNU roff typesetting system.
#
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This file is set up so you can do
#   make -f generate/Makefile
# in the parent directory of this directory.

# Write font descriptions to this directory.
outdir=$(srcdir)/..

srcdir=generate

SFD=$(srcdir)/symbolsl.sfd
AFM=$(outdir)/symbolsl.afm
PFB=$(outdir)/symbolsl.pfb

all: $(AFM) $(PFB)

$(AFM) $(PFB): $(SFD)
	fontforge --lang=ff -c 'Open("$(SFD)");Generate("$(PFB)")' \
	  && mv $(AFM) $(AFM).in \
	  && mv $(PFB) $(PFB).in \

clean:
	cd $(outdir) \
	  && $(RM) symbolsl.afm $(PFB).in

.PHONY: all clean

# Local Variables:
# mode: makefile
# fill-column: 72
# End:
# vim: set textwidth=72:
