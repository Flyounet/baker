
PREFIX=/usr/local

install:
	cp -f baker $(PREFIX)/bin/baker
	if [ ! -d "/usr/share/baker" ]; then mkdir -p "/usr/share/baker"; fi
	cp -r public /usr/share/baker/public
	cp -r public_black /usr/share/baker/public_black
	cp -r layout /usr/share/baker/layout
	cp -r layout_black /usr/share/baker/layout_black
	cp -f Makefile "/usr/share/baker/Makefile"

uninstall:
	rm -f $(PREFIX)/bin/baker
	cd /usr/share && rm -rf -- baker/

.PHONY: install uninstall
