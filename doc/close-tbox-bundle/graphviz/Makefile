diagrams:	svg pdf

svg:	initial.svg bidetail.svg step1.svg step2.svg step3.svg

pdf:	initial.pdf bidetail.pdf step1.pdf step2.pdf step3.pdf

%.svg : %.dot macros.m4
	m4 macros.m4 $< | dot -Tsvg > $@

%.pdf : %.dot macros.m4
	m4 macros.m4 $< | dot -Tpdf > $@

clean:
	rm -rf *.svg *.pdf
