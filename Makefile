help:
		@echo fetch - grab latest tachyons
		@echo server - run a local server

fetch:
		wget https://raw.githubusercontent.com/tachyons-css/tachyons/master/css/tachyons.min.css -O public/css/tachyons.min.css

server:
		TITLE="Quarantine Poems Anthology" TABLE="Poems" APP_KEY="your app key" API_KEY="your api key" bundle exec rerun rackup
