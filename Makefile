all:
	zip -r out *
	mv out.zip out.love
	love out.love
