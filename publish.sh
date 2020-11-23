#!/bin/sh

flutter pub publish --dry-run

VERSION=$(grep 'version:' pubspec.yaml | awk '{ print $2 }' | cut -d '+' -f 1 | tr -d '\n')
git tag -a "$VERSION"
git push origin --tags

flutter pub publish
