# opensource COBOL 4j development environment (Docker)

> This image is a fork of https://github.com/opensourcecobol/opensourcecobol4j-dockerfile which uses https://github.com/opensourcecobol/opensourcecobol4j both licenced under GPL-3.0 license.

## Usage ##

```
docker run -v $(pwd):/output ghcr.io/hfhbd/cobol2java HELLO.cbl
```
This will create `Hello.java` and `Hello.class` in the current/mounted directory.
