.PHONY: init collection collect second-pass validate index clobber black clean prune
.SECONDARY:
.DELETE_ON_ERROR:
.SUFFIXES: .json

RESOURCE_DIR=collection/resource/
VALIDATION_DIR=validation/
TMP_DIR=var/tmp/
CSV_DIR=var/csv/

DATASET_NAMES=brownfield-land
DATASET_FILES=dataset/brownfield-land.csv

LOG_FILES:=$(wildcard collection/log/*/*.json)
LOG_FILES_TODAY:=collection/log/$(shell date +%Y-%m-%d)/

VALIDATION_FILES:=$(addsuffix .json,$(subst $(RESOURCE_DIR),$(VALIDATION_DIR),$(wildcard $(RESOURCE_DIR)*)))
COLLECTION_INDEX=collection/index.json


all: collect second-pass


collect:	$(DATASET_FILES)
	python3 bin/collector.py $(DATASET_NAMES)

second-pass:
	@make --no-print-directory validate index

validate: $(VALIDATION_FILES)
	@:

# TBD: deal with broken file ..
# validation/7ba205f5d2619398a931669c1e6d4c8850f6fbefe2d6838a3ebbbe5f9200b702.json

$(VALIDATION_DIR)%.json: $(RESOURCE_DIR)%
	@mkdir -p $(TMP_DIR) $(CSV_DIR) $(VALIDATION_DIR)
	validate --exclude-input --exclude-rows --tmp-dir "$(TMP_DIR)" --save-dir "$(CSV_DIR)" --file $< --output $@


index: $(COLLECTION_INDEX)
	@:

$(COLLECTION_INDEX): bin/index.py $(DATASET_FILES) $(LOG_FILES) $(VALIDATION_FILES)
	bin/index.py brownfield-land

black:
	black .

clobber::
	rm -rf $(LOG_FILES_TODAY)

init::
	pip3 install --upgrade -r requirements.txt

prune:
	rm -rf ./var $(VALIDATION_DIR)
