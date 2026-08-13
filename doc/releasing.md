# Release checklist

Use this checklist when preparing a release. A successful development build is
not, by itself, a stable API commitment.

## Prepare

- Review `CHANGELOG.md` and describe any migration required by public changes.
- Confirm the package description, version, repository links, topics, and
  screenshots in `pubspec.yaml` are accurate.
- Confirm all intended public declarations are documented and listed in
  `tool/public_api_declarations.txt`.
- Review the Gallery on the platforms relevant to the release.

## Verify

Run from the repository root:

```sh
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
dart run tool/check_public_api.dart
dart run tool/check_package_screenshots.dart
flutter analyze
flutter test
flutter pub publish --dry-run
```

Then verify the Gallery:

```sh
cd example
flutter analyze
flutter test
flutter build web --release
```

Review Golden changes on Windows before accepting them. Confirm the hosted
quality workflow is green, including the minimum Flutter job and native Gallery
builds.

## Publish

- Tag the reviewed commit and publish from that exact commit.
- Verify the published package page, README images, API documentation, and
  changelog after publication.
- Record any follow-up work as issues rather than silently carrying it into the
  next release.
