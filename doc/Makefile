### build pdf and docx of markdown files using pandoc
### pandoc needs to be installed!

MD = $(wildcard *.md)

DOCX = $(MD:%.md=%.docx)
PDF = $(MD:%.md=%.pdf)

all: docx pdf

docx: $(DOCX)
pdf: $(PDF)

%.docx: %.md
	pandoc -o $@ $<

%.pdf: %.md
	pandoc -o $@ $<

clean: 
	rm -f $(DOCX) $(PDF)
