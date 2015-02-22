default_target: all

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

all: mfiles/snoptmex.* mfiles/README $(BUILD_PREFIX)/matlab/addpath_snopt.m $(BUILD_PREFIX)/matlab/rmpath_snopt.m

mfiles/README :
	echo "Writing a fake README to be recognized as studentsnopt in Drake"
	echo "studentVersions" > mfiles/README

mfiles/snoptmex.* :
	if [ -e snoptmex.* ]; then echo "Copying the mex library file into mfiles" && cp snoptmex.* mfiles; else echo "ERROR: No Snopt mex library found. Please place a snoptmex library file in $(PWD)" && exit 1; fi;

$(BUILD_PREFIX)/matlab/addpath_snopt.m :
	@mkdir -p $(BUILD_PREFIX)/matlab
	echo "Writing $(BUILD_PREFIX)/matlab/addpath_snopt.m"
	echo "function addpath_snopt()\n\n \
	  root = fullfile('$(shell pwd)','mfiles');\n \
		addpath(fullfile(root));\n \
		end\n \
		\n" \
		> $(BUILD_PREFIX)/matlab/addpath_snopt.m

$(BUILD_PREFIX)/matlab/rmpath_snopt.m :
	@mkdir -p $(BUILD_PREFIX)/matlab
	echo "Writing $(BUILD_PREFIX)/matlab/rmpath_snopt.m"
	echo "function rmpath_snopt()\n\n \
		root = fullfile('$(shell pwd)','mfiles');\n \
		addpath(fullfile(root));\n \
		end\n \
		\n" \
		> $(BUILD_PREFIX)/matlab/rmpath_snopt.m

clean:
	-if [ -e mfiles/README ]; then echo "Deleting mfiles/README" && rm mfiles/README; fi
	-if [ -e mfiles/snoptmex.* ]; then echo "Deleting mfiles/snoptmex.*" && rm mfiles/snoptmex.*; fi
	-if [ -e $(BUILD_PREFIX)/matlab/addpath_snopt.m ]; then echo "Deleting $(BUILD_PREFIX)/matlab/addpath_snopt.m" && rm $(BUILD_PREFIX)/matlab/addpath_snopt.m; fi
	-if [ -e $(BUILD_PREFIX)/matlab/rmpath_snopt.m ]; then echo "Deleting $(BUILD_PREFIX)/matlab/rmpath_snopt.m" && rm $(BUILD_PREFIX)/matlab/rmpath_snopt.m; fi

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:
