# THIS MAKEFILE REQUIRES SH TO RUN

# preprocess and compile commands
CMD_PREPROCESS := gcc -E -x c
CMD_COMPILE    := nmlc -c -o china-set-metro.grf

# render commands
RENDER_LIST_FILE   := render_list.json
DEFAULT_MANIFEST   := $(shell jq -r '.default_manifest' $(RENDER_LIST_FILE))
DEFAULT_PALETTE    := $(shell jq -r '.default_palette' $(RENDER_LIST_FILE))
CMD_RENDER         := renderobject -overwrite

# vox files
VOX := $(shell find gfx -name "*.vox")

# corresponding png files
PNG_8BPP  := $(VOX:.vox=_8bpp.png)
PNG_MASK  := $(VOX:.vox=_mask.png)
PNG_32BPP := $(VOX:.vox=_32bpp.png)

PNG := $(PNG_8BPP) $(PNG_MASK) $(PNG_32BPP)

# convert vox to png
%_8bpp.png %_mask.png %_32bpp.png: %.vox
	@export MANIFEST=$(shell jq -r --arg key "$<" --arg default "$(DEFAULT_MANIFEST)" \
						  'if .[$$key] and .[$$key].manifest then .[$$key].manifest else $$default end' $(RENDER_LIST_FILE)); \
	export PALETTE=$(shell jq -r --arg key "$<" --arg default "$(DEFAULT_PALETTE)" \
						  'if .[$$key] and .[$$key].palette then .[$$key].palette else $$default end' $(RENDER_LIST_FILE)); \
	echo "Rendering $<, using manifest $$MANIFEST" and palette $$PALETTE; \
	$(CMD_RENDER) -manifest $$MANIFEST -palette $$PALETTE -input $<

.PHONY: all render preprocess compile

all: render preprocess compile
	@echo "========== All tasks complete =========="

# default target, renders all voxel models in this repo
render: $(PNG)
	@echo "========== Rendering complete =========="

# don't put anything at the root!
SECONDARY_PNML := $(shell find src/*/ -name "*.pnml")
PNML := $(shell find src/*/ -name "*.pnml")

# batch preprocess all pnml files and all secondary pnml files
preprocess: $(PNML)
	@echo "#include \"metro.pnml\"" > metro.temp; \
	for file in $(SECONDARY_PNML); do \
		echo "#include \"$$file\"" >> metro.temp; \
	done; \
	$(CMD_PREPROCESS) metro.temp > metro.nml; \
	rm metro.temp
	@echo "========== Preprocessing complete =========="

# compile the metro.nml file
compile: preprocess
	$(CMD_COMPILE) metro.nml
	@echo "========== Compiling complete =========="

# clean up
clean:
	rm -f metro.nml
	rm -f china-set-metro.grf
	rm -f $(PNG)
	@echo "========== Clean up complete =========="
