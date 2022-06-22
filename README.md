# Cmake monorepo example with optional package manager dependency management

This project consists of the following individual repos in one big monorepo:

- `a/`
- `b/`
- `c/`
- `d/`
- `libc/`
- `app/`
- `app2/`

The whole idea of this example repository is to show that we can compile the
apps and libs with different toolchains for different environments. Especially
the following things are shown:

1. Using legacy package management or one large docker image, the whole project
   and its libraries can be built in one large step for a given toolchain file
   using the workflow:

   ```bash
   cmake -DCMAKE_TOOLCHAIN_FILE=cmake/host.cmake -B build-host -S .
   make -C build-host

   cmake -DCMAKE_TOOLCHAIN_FILE=cmake/cross.cmake -B build-cross -S .
   make -C build-cross
   ```
2. Using `nix`, individual packages can be built for both toolchains as
   packages in a way that they can be cached individually and reference each
   other:

   ```bash
   nix-build release.nix -A myapp
   nix-build release.nix -A myapp-cross
   ```
3. Legacy workflow only: The `app2` is only compiled if we use the
   `cross.cmake` toolchain. This mechanism can be used to compile e.g. unit
   tests only when compiling for the current build host.
4. Transparently (from cmake app and libs perspective) compile with a custom
   libc and with the host systems libc. The app's cmake definitions do not need
   to care about which toolchain is used currently.
5. We are not compiling a specific lib with different compiler flags in a
   single cmake invocation (e.g. doing something like `lib-hello-${LIB-TYPE}`)
   which would make the `find_package` trick very cumbersome.
6. We have only two points where we define compiler/toolchain settings which
   are the cmake toolchain files and the release.nix. The settings defined
   there are passed down to every other app avoiding to redefine every compiler
   flag in every project.

# Workflow PROs and CONs

Let's compare what each workflow buys us

## Legacy workflow

### PRO Legacy

- Fine-granular rebuilds: If one file is touched, the build system will find out
  itself what the minimal rebuild set is. Incremental builds are faster during
  development.
- Legacy workflow is what people are used to:
  Either install all needed packages globally, or run a docker image as
  developer shell and be able to edit anything in the monorepo

### CON Legacy

- The dependency closure is the superset of all modules. All modules see all
  dependencies.
- If the repository is checked out, everything in this folder that is not a
  globally available dependency, must be rebuilt.
  Although the libraries in this repo are libraries like the globally installed
  ones, there is an artificial difference between them.

## Nix workflow

### Pro Nix

- Fine granular dependency closures: For every module, the right minimal
  closure can be instantiated without unneeded dependencies. This enforces
  structure.
- Libraries can be cached by external machines.
- There is no difference between globally available system libraries and local
  libraries any longer. Both can be substituted by locally patched versions
  without putting the burden on the developer to manage include/link settings.
- As it makes no difference if a library is in this repository or anywhere else,
  libraries can easily be "outsourced" to other repos.

### Contra Nix

- It may look alien to users of legacy systems that another shell has to be
  started for development in every module of this project.
- If something is changed in e.g. library `D`, then `A` and `MyApp` have to be
  not only relinked but rebuilt. The smaller the individual packages are, the
  lesser is this a problem.open source

# References

The `find_package`-NOP macro idea originates from Daniel Pfeifer's talk about
CMake at the C++Now 2017 conference:
https://www.youtube.com/watch?v=bsXLMQ6WgIk
