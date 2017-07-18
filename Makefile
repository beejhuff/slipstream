FORMS=terms
COMMONFORM=node_modules/.bin/commonform
PRODUCTS=cform hash docx pdf html
RELEASE=release
TARGETS=$(foreach type,$(PRODUCTS),$(addsuffix .$(type),terms))

all: $(addprefix $(RELEASE)/,$(TARGETS))

%.pdf: %.docx
	unoconv $<

$(RELEASE)/%.hash: %.cform | $(COMMONFORM) $(RELEASE)
	$(COMMONFORM) hash $< > $@

$(RELEASE)/%.docx: %.cform title blanks.json | $(COMMONFORM) $(RELEASE)
	$(COMMONFORM) render --format docx --title "$(shell cat title)" --number outline --indent-margins --left-align-title --blanks blanks.json $< >$@

$(RELEASE)/%.html: %.cform title blanks.json | $(COMMONFORM) $(RELEASE)
	$(COMMONFORM) render --format html5 --title "$(shell cat title)" --blanks blanks.json $< >$@

$(RELEASE)/%.cform: %.cform | $(COMMONFORM) $(RELEASE)
	$(COMMONFORM) render --format native < $< > $@

$(COMMONFORM):
	npm install

$(RELEASE):
	mkdir $(RELEASE)

.PHONY: clean docker

clean:
	rm -rf $(RELEASE)

docker:
	docker build -t software-service-terms .
	docker run --name software-service-terms software-service-terms
	docker cp software-service-terms:/app/$(RELEASE) .
	docker rm software-service-terms
