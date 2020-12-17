-*- encoding: utf-8 -*-

hex: hexagons-a-fr.png hexagons-a-en.png hexagons-b.png hexagons-c.png hexagons-on.png hexagons-o.png hexagons-n.png

hexagons-a-fr.png: hexagons.pdf
	convert -crop '800x550+500+500' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-a-fr.png
	mv hexagons-a-fr-0.png hexagons-a-fr.png
	rm hexagons-a-fr-1.png

hexagons-a-en.png: hexagons.pdf
	convert -crop '800x550+1320+500' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-a-en.png
	mv hexagons-a-en-0.png hexagons-a-en.png
	rm hexagons-a-en-1.png

hexagons-b.png: hexagons.pdf
	convert -crop '900x600+500+1100' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-b.png
	mv hexagons-b-0.png hexagons-b.png
	rm hexagons-b-1.png

hexagons-c.png: hexagons.pdf
	convert -crop '900x900+500+1700' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-c.png
	mv hexagons-c-0.png hexagons-c.png

hexagons-on.png: hexagons.pdf
	convert -crop '900x900+500+500' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-on.png
	mv hexagons-on-1.png hexagons-on.png
	rm hexagons-on-0.png

hexagons-o.png: hexagons.pdf
	convert -crop '1000x900+1300+1300' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-o.png
	mv hexagons-o-1.png hexagons-o.png
	rm hexagons-o-0.png

hexagons-n.png: hexagons.pdf
	convert -crop '900x1200+500+1900' -density 300 -background white -alpha deactivate hexagons.pdf hexagons-n.png
	mv hexagons-n-1.png hexagons-n.png
	rm hexagons-n-0.png
	display hexagons-n.png

hexagons.pdf: hexagons.tex
	lualatex hexagons.tex
