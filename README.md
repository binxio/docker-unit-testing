# PrivateBin unit testing docker image

**PrivateBin** is a minimalist, open source online [pastebin](https://en.wikipedia.org/wiki/Pastebin) where the server has zero knowledge of pasted data. Data is encrypted and decrypted in the browser using 256bit AES in [Galois Counter mode](https://en.wikipedia.org/wiki/Galois/Counter_Mode).

This repository contains the Dockerfile and resources needed to create a docker image with a pre-installed phpunit & mocha. The image is based on the docker hub php:7.0-cli-alpine image, extended with the GD module & nodejs. Run the container with your local PrivateBin repository as a read-only volume and it will run both the PHP and JavaScript test suites in parallel and return the results.

## Running the image

Assuming you have docker successfully installed and internet access, you can fetch and run the image from the docker hub like this:

```bash
docker run --rm --read-only -v ~/PrivateBin:/srv:ro privatebin/unit-testing
```

The parameters in detail:

- `-v ~/PrivateBin:/srv:ro` - Replace `~/PrivateBin` with the location of the checked out PrivateBin repository on your machine. It is recommended to mount it read-only, which guarantees that your repository isn't damaged by a accidentally destructive test case in it.
- `--read-only` - This image supports running in read-only mode. Only /tmp may be written into.
- `-rm` - Remove the container after the run. This safes you doing a cleanup on your docker environment, if you run the image frequently.

Note: Inside the container, the first thing that will be done is to copy your repository into /tmp/repo. The unit tests are then run in this copy. While this slows things done a bit, it ensures that a test script inside your repository can't accidentally delete objects in it.

### Running just phpunit or mocha

Optionally you can run just the PHP or Javascript unit tests by specifying the optional parameter:

```bash
docker run --rm --read-only -v ~/PrivateBin:/srv:ro privatebin/unit-testing phpunit
docker run --rm --read-only -v ~/PrivateBin:/srv:ro privatebin/unit-testing mocha
```

## Rolling your own image

To reproduce the image, run:

```bash
docker build -t privatebin/unit-testing .
```

Nodejs has to be built from source on Alpine, since it doesn't ship with standard C++ libraries. Grab a cup of tea.

### Behind the scenes

Since both unit test frameworks process the test cases linearly, both use only one CPU core. Nowadays most system have more then one, so the entrypoint script launces mocha in the background and phpunit in the foreground. On systems with 2 or more CPUs they can therefore run in parallel. On a recently modern amd64 CPU phpunit should take about 14s to run and mocha around 15s, hence its output gets displayed after phpunit.
