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

Page-223.pdf: Page-223.tex
	lualatex Page-223.tex
