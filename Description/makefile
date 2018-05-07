-*- encoding: utf-8 -*-

visu: voitures-0.png
	display voitures-0.png

voitures-0.png: voitures.pdf
	convert -crop '200x180+100+100' -background white -alpha deactivate voitures.pdf voitures.png

voitures.pdf: voitures.lua voitures.tex
	lualatex voitures.tex
