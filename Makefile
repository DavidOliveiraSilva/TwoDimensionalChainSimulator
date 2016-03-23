all:
	rm -rf out.love
	zip -r out *
	mv out.zip out.love
	love out.love
