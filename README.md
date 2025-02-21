# Base Autograder Image

Source for the `ucsc-cse-114a/base-autograder-image` Docker images.

The image builds off of the [edulinq/grader.python](https://github.com/edulinq/autograder-docker-python) images.
This images adds the required packages to grade Haskell assignments and adds the dependencies CSE-114A projects at UCSC.

## Motivation

The base autograder image should install a superset of the required packages of all of the assignments in CSE114A.
By pre-installing Haskell packages that the projects need, the build time of each assignments' grader is reduced.

## Dummy Package

This haskell package is used purely to ensure proper installation of the necessary packages required by the `base-autograder-image`.
The `stack.yaml` in `base-autograder-image` will not download and build dependencies unless a package requires them.

We created this "dummy-package" to ensure the image properly installs all required packages.
Since Haskell does not install packages for a `stack.yaml` unless a project's build (i.e. the "dummy-package's" build) depends on the packages,
`dummy-package.cabal` must include the same superset of packages in the `build-depends` field.

## Maintenance

To properly install these packages, they must be added to this directories `stack.yaml`.
Additionally, the `dummy-package/dummy-package.cabal` must include these packages in the `build-depends` field.
If you need to update a version of a package, do so in the main `stack.yaml`.

In the future, there could be a script to take the requirements from the `stack.yaml` and write them into the `build-depends` field.
This would simplify this process and ensure the `base-autograder-image` properly installs all required packages for CSE-114A's assignments.

## Limitations

Currently, the base image only supports assignments that use GHC version 9.4.7.
All assignments must use the same Stack resolver. This ensures proper dependency caching to reduce assignment build times.
