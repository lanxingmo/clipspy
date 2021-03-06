PYTHON			?= python
CLIPS_VERSION		?= 6.30
CLIPS_SOURCE_URL	?= "https://downloads.sourceforge.net/project/clipsrules/CLIPS/6.30/clips_core_source_630.zip"
MAKEFILE_NAME		?= makefile.lib
SHARED_LIBRARY_DIR	?= /usr/lib

.PHONY: clips clipspy test install clean

all: clips_source clips clipspy

clips_source:
	wget -O clips.zip $(CLIPS_SOURCE_URL)
	unzip -jo clips.zip -d clips_source

clips: clips_source
	cp clips_source/$(MAKEFILE_NAME) clips_source/Makefile
	sed -i 's/gcc -c/gcc -fPIC -c/g' clips_source/Makefile
	$(MAKE) -C clips_source
	ld -G clips_source/*.o -o clips_source/libclips.so

clipspy: clips
	$(PYTHON) setup.py build_ext --include-dirs clips_source       	\
		--library-dirs clips_source

test: clipspy
	cp build/lib.*/clips/_clips*.so clips
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:clips_source			\
		$(PYTHON) -m pytest -v

install: clipspy
	cp clips_source/libclips.so		 			\
	 	$(SHARED_LIBRARY_DIR)/libclips.so.$(CLIPS_VERSION)
	ln -s $(SHARED_LIBRARY_DIR)/libclips.so.$(CLIPS_VERSION)	\
	 	$(SHARED_LIBRARY_DIR)/libclips.so.6
	ldconfig -n -v $(SHARED_LIBRARY_DIR)
	$(PYTHON) setup.py install

clean:
	-rm clips.zip
	-rm -fr clips_source build dist clipspy.egg-info
