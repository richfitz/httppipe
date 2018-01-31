# httppipe

This is a small proof-of-concept to try and get a http client working over Windows named pipes.  I need this in [`stevedore`](https://github.com/richfitz/stevedore) as this is the default configuration of docker on windows.

Ideally this could be done via the `curl` package (so that things would work directly with packages that `curl`/`httr`) but it's not clear that libcurl supports this.

A better bet than this would probably be native named pipe support via some C code.  But that probably requires some knowledge of the Windows API, and support via that route could be added to this package.

So in the meanttime, this package calls out to the Python code that the python docker SDK uses, via `reticulate`

For compatibility testing, a unix socket connector is included.  This may be removed once the windows support is stable (rendering the package a bit empty on non-windows platforms!).

For other approaches to named pipe support from R, the packages `pdbRPC` and `httpuv` both implement some.
