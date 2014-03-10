.PHONY: all

all: build

deps:
	mix deps.get

deps_release:
	cd deps/relex; mix
	cd ../../
	cd deps/pogo; mix
	cd ../../

deps_compile:
	mix deps.compile

compile:
	mix compile

test: build
	mix test

build: deps deps_release deps_compile compile

run: build
	mix server

rel: build
	mix relex.assemble

package: build
	mix archive

rel_clean:
	mix relex.clean

clean:
	rm -rf _build deps cors_echo
	rm -rf *.ez
	rm -rf nil
