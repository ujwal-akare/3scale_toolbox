# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

### Changed

### Fixed

## [0.4.0]

### Added

- `3scale update` that updates existing service
- `3scale copy` copies `backend_version`

## [0.3.0]

### Changed
- Require Ruby >= 2.1 in the gemspec

## [0.2.2] - 2016-04-21
### Fixed
- `3scale import csv` importing mapping rules

## [0.2.1] - 2016-04-12
### Added
- `3scale copy` added new argument --target-system-name

## [0.2.0] - 2016-03-30
### Added
- `3scale copy service` can copy between different accounts

### Changed
- `3scale copy` changed arguments (from endpoint & provider key to source, see --help)

### Fixed
- `3cale copy help` now prints correct help

## [0.1.1] - 2016-03-16
### Added
- `3scale copy service` now copies Proxy and Mapping Rules

## [0.1.0] - 2016-03-11
### Added
- `3scale` command
- `3scale copy service` command to copy a service
  including its metrics, methods, application plans and their usage limits

[Unreleased]: https://github.com/3scale/3scale_toolbox/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.3.0
[0.2.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.2.0
[0.1.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.1.1
[0.1.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.1.0
