SHELL := /bin/bash
PANDOC:=pandoc --normalize --smart --write=html5+yaml_metadata_block+footnotes --read=markdown --standalone  --section-divs -V title:scuttlebutt --template ./template.html --toc --toc-depth=2
BROWSERIFY:=browserify -d js/index.js

html/index.html: index.md html/bundle.js html/style.css html/assets/ add_containers.js template.html
	echo '<script type="text/javascript" src="./bundle.js" async></script>' > html/bundle.html
	$(PANDOC) --include-in-header=html/bundle.html -c style.css index.md | ./add_containers.js > html/index.html
	rm html/bundle.html

html/bundle.js: js/* ../lib/gossip.js
	$(BROWSERIFY) -o html/bundle.js

html/style.css: style.css 
	cp style.css html/style.css

html/assets/: assets/*
	mkdir -p html/assets
	cp assets/* html/assets

clean: 
	rm -rf html

install:
	@command -v node || echo "No node on you're path. Please install node and make sure it is on your \$PATH variable"
	@command -v pandoc || echo "No pandoc, Please install pandoc and make sure it is on your path"
	mkdir -p html
	npm install

prod: 
	$(PANDOC) -V include-after:"<script class=bundle></script>" -V header-includes:"<style class=style></style>" index.md > html/temp.html
	cp -r html/ ../.git/html
	git checkout gh-pages
	cp -r ../.git/html/* ../
	git add ../assets/* ../index.html ../bundle.js ../style.css
	git commit -a -m "update"

