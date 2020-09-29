# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.59] - 2020-09-29
### Add
- Add -b|--batch parameter.

## [1.58.1] - 2017-06-20
### Add
- Add CHANGELOG.md.

### Removed
- Removed changelog information in script code.

### Changed
- Fixed text encoding.

## [1.58]
### Fixed
- Fix http_user and http_group when deploy.

## [1.57]
### Fixed
- Fix -d|--deploy-path parameter error.

## [1.56]
## Added
- Add new read parameters function.
- Add coloured output.

## [1.55]
### Added
- Add new license details.
- Add config file feature.

### Changed
- Change script name. 
- Change default httpd's user and group.
- Minor visual changes.

## [1.54]
### Added
- Add --trust-server-cert.

## [1.53]
### Fixed
- Fix auto-deploy errors.

## [1.52]
### Added
- Add -d (deploy) option to auto-deploy files.
- Add -non-interactive parameter to svn queries.

## [1.51]
### Fixed
- Fix problem with download changes and deleted files between revisions (add @REV at the end of old files).

## [1.5]
### Fixed
- Fix problem with download changes and deleted files between revisions (add @REV at the end of old files).

## [1.4]
### Changed
- Modified .revision to output valid CSV format and include username.

## [1.3.3]
### Changed
- Change umask to 0027.

## [1.3.2]
### Added
- Add comments to export bash file.
- Add --no-same-permissions, --no-overwrite-dir to tar xvzf on export bash file.

### Changed
- Change default permissions: directories *755->750*, files *644->640*.
- Disable individual export.
- Comment file and directories find & replace permissions on ALL files.

## [1.3.1]
### Added
- Capture httpd user and group from httpd config file.

### Removed
- Remove full comments at the end of script.

## [1.3]
### Added
- Add escape character @ at individual/changes (http://svnbook.red-bean.com/en/1.5/svn.advanced.pegrevs.html)

## [1.2.9]
### Added
- Add double-quotes for password and username.
- Show *full* results on screen.
- Add escape character @ at individual/changes (http://svnbook.red-bean.com/en/1.5/svn.advanced.pegrevs.html).

## [1.2.8]
### Removed
- Add GNU text.

## [1.2.7]
### Removed
- Remove SVN Password parameter.

## [1.2.6]
### Added
- Add username/password to changes/individual.

## [1.2.5]
### Added
- Created exclude_files & exclude_folders variables.

## [1.2.4]
# Added
- Add double-quote to remove file/folder.

## [1.2.3]
### Added
- Remove check_version_url before script execution.

## [1.2.2]
### Fixed
- Fix file names with blank spaces in *changes* and *individual* exports.

## [1.2.1]
### Added
- Add *build* to Remove unnecessary files.

## [1.2.0]
### Added
- Add option *check_version_online*.

## [1.1.1]
### Fixed
- Remove files from destination if removed between revisions error fixed.

## [1.0.2]
### Added
- Add *.settings* to Remove unnecessary files.

## [1.0.1]
### Changed
- Minor changes.

## [1.0]
### Added
- First FINAL version.

## [0.7]
### Changed
- Minor changes.

## [0.6]
### Changed
- Minor changes.

## [0.5]
### Added
-Add *_notes* to Remove unnecessary files.
- Add *rm . -rf* if *-t full*.

## [0.4]
### Added
- Remove unnecessary files.

## [0.3]
### Added
- Color messages in console.

## [0.2]
### Changes
- New engine for export types.

## [0.1]
### Add
- Initial realease.
