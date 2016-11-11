
all: build run

clean:
	@vapor clean

build:
	@vapor build

run:
	@vapor run

watch:
	@watchman-make -p 'Resources/**/*.*' 'Public/**/*.*' 'Sources/**/*.*' -t 'all'
