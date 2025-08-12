# 🌄 PDS Engineering Actions: Base Image


[GitHub Actions](https://github.com/features/actions) let you run workflows for software repositories for such things as continuous integration, code quality, documentation extraction, continuous delivery, and so forth. The [Planetary Data System (PDS)](https://pds.nasa.gov/) uses GitHub Actions for these purposes.

Workflows consist of _actions_, each of which can be executed using JavaScript, so-called "composite" actions (essentially shell macros), or as [Docker](https://www.docker.com/) containers. Docker-based actions give you the most flexibility, letting you define your action in whatever programming language you enjoy with access to whatever libraries and APIs are convenient (so long as it's a Linux-based container).

However, Docker-based actions are the slowest in GitHub Actions as GitHub spins up a new Docker machine, builds your image, installs it into a container, runs it, and then tears it all down for _every_ execution of your action. For actions that require a lot of setup (in terms of C libraries, Python dependencies, Java APIs, and so forth), this can make execution painfully slow.

Enter _this_ image. By deriving specific GitHub Actions from _this_ image, we make a "snapshot" of all the dependencies typically needed by GitHub actions in one place.

Of course, this makes a few assumptions:

- PDS GitHub actions will need Python 3.9.16.
- They'll run on Alpine Linux 3.16.
- They'll have access to development tools:
  - GCC
  - MUSL C library
  - OpenSSL
  - `libxml2`, `libxslt`, and `libffi`
  - GnuPG
- But wait there's more
  - Git
  - Ruby (yes, in addition to Python)
  - Java (yes, in addition to Ruby)
  - Node.js (yes, in addition to Java)

And we might expand on this in the future.


## ℹ️ Using this Base

To use this base image in your own Docker-based action, simply derive from it in your action's `Dockerfile`:

```Dockerfile
FROM nasapds/github-actions-base:latest

# Action-specific stuff here
```


## 🔧 Maintaining this Base

To update this base image, just make changes to the `Dockerfile` and, if needed, the `m2-repository.tar.bz2`.

To make a release of this image on the [Docker Hub](https://hub.docker.com/), do a push to GitHub:

- A push to the `main` branch will trigger an automatic build of the image with the `:latest` tag and push it to `nasapds/github-actions-base:latest` on the Docker Hub.
- A push to a `vX.Y.Z` tag will trigger an automatic build of the image with the `:X.Y.Z` tag and push it to `nasapds/github-actions-base:X.Y.Z`, where `X.Y.Z` is a [semantic version](https://www.semver.org/).

But if you ever need to do that by hand, try this:

```console
docker login --username nasapds
docker buildx build --tag nasapds/github-actions-base:TAGNAME --platform linux/amd64,linux/arm64 --push .
```

Substitute `:TAGNAME` with whatever's appropriate.


## ⏰ Future Work

- 🤡 Well, until the PDS makes its own group account on the Docker Hub, this stuff lives in `nasapds`'s account
- 😮 You'd think [GitHub Packages](https://github.com/features/packages) would be an alternative, but [GitHub Actions doesn't support using images from GitHub Packages](https://github.community/t/use-docker-image-from-github-packages-as-container/118709)!
- 💀 There isn't even [anonymous pulls of images from GitHub Packages](https://github.community/t/make-it-possible-to-pull-docker-images-anonymously-from-github-package-registry/16677)!
- 😑 Apparently engineers at GitHub are recommending to [migrate from GitHub Packages to the new GitHub Container Registry](https://docs.github.com/en/packages/getting-started-with-github-container-registry/migrating-to-github-container-registry-for-docker-images). The Container Registry is currently in public β.
- 💽 It's currently ~~213~~ ~~216~~ ~~579~~ ~~593~~ ~~790~~ ~~815~~ ~~669~~ ~~931~~
 MiB. ~~Let's try and keep it around there 😲 (Thanks, Java. And C++. But mostly Java.)~~ YIKES. It's 1.15 GiB now!
 
