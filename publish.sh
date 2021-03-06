#!/bin/sh

fvm install
fvm flutter pub publish --dry-run

VERSION=$(grep 'version:' pubspec.yaml | awk '{ print $2 }' | cut -d '+' -f 1 | tr -d '\n')
git tag -a "$VERSION" -m "$VERSION"
git push origin --tags

fvm flutter pub publish
