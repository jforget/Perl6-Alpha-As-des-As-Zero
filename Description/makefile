-*- encoding: utf-8 -*-

texte: description-fr-txt.html

description-fr-txt.html: description-fr.html
	perl enlever-images.pl description-fr.html description-fr-txt.html

html: description-fr.html

description-fr.html: description-fr.pod
	pod2html --infile description-fr.pod --outfile description-fr.html 

visu: voitures-0.png
	display voitures-0.png

voitures-0.png: voitures.pdf
	convert -crop '600x540+100+100' -background white -alpha deactivate voitures.pdf voitures.png

voitures.pdf: voitures.lua voitures.tex
	lualatex voitures.tex

page-223: Page-223-a.png Page-223-b.png Page-223-c.png
	display Page-223-c.png

Page-223-a.png: Page-223.pdf
	convert -crop '1400x650+500+500' -density 300 -background white -alpha deactivate Page-223.pdf Page-223-a.png

Page-223-b.png: Page-223.pdf
	convert -crop '1400x650+500+1150' -density 300 -background white -alpha deactivate Page-223.pdf Page-223-b.png

Page-223-c.png: Page-223.pdf
	convert -crop '1400x650+500+1770' -density 300 -background white -alpha deactivate Page-223.pdf Page-223-c.png

Page-223.pdf: Page-223.tex
	lualatex Page-223.tex
