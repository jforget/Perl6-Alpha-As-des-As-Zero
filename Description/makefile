-*- encoding: utf-8 -*-

html: description.html

description.html: description.pod
	pod2html --infile description.pod --outfile description.html 

visu: voitures-0.png
	display voitures-0.png

voitures-0.png: voitures.pdf
	convert -crop '200x180+100+100' -background white -alpha deactivate voitures.pdf voitures.png

voitures.pdf: voitures.lua voitures.tex
	lualatex voitures.tex
