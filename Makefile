build: clean
	mkdir build
	mkdir build/img
	mkdir build/snd
	
	cp -r src/* build/
	
	convert img/schlagsahne.png -resize 50% build/img/schlagsahne.png
	cp img/blue_sky_800x600.jpg build/img/background.jpg
	cp img/part1.png build/img/part1.png
	cp img/insel/insel2.png build/img/island.png
	
	cd build && zip -r ../p1.zip *
	mv p1.zip p1.love

clean:
	rm -f p1.zip p1.love
	rm -rf build

run: build
	love p1.love
