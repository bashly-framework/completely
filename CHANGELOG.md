Changelog
========================================

v0.7.2 - 2025-08-04
----------------------------------------

- Fix JSON schema
- Drop support for Ruby 3.0 and 3.1


v0.7.1 - 2025-04-04
----------------------------------------

- Add support for modifying the `complete` command options


v0.7.0 - 2024-11-29
----------------------------------------

- Update instructions and template for obtaining list of git branches
- Add support for nested configuration
- Add `completely init --nested` and explain nested syntax in the README


v0.6.3 - 2024-07-05
----------------------------------------

- Allow using colon, semicolon and equal sign in completions
- Check output with shfmt
- Revert wordbreak (colon) patch


v0.6.2 - 2024-02-08
----------------------------------------

- Update possible completions installation directories
- Build docker images automatically


v0.6.1 - 2023-06-23
----------------------------------------

- Add ability to uninstall a completion script


v0.6.0 - 2023-06-23
----------------------------------------

- Refactor install command and add an Installer model
- Drop support for Ruby 2.7
- Change exception classes


v0.5.4 - 2023-04-21
----------------------------------------

- Add `completely install` command


v0.5.3 - 2023-01-31
----------------------------------------

- Upgrade dependencies


v0.5.2 - 2022-12-02
----------------------------------------

- Improve test command output and allow multiple complines in one run


v0.5.1 - 2022-11-28
----------------------------------------

- Refactor with rubocop
- Fix broken script when wildcards follow the first word
- Show warning when running the test command on an invalid file


v0.5.0 - 2022-09-04
----------------------------------------

- Add docker release
- Fix shellcheck SC2162 in the generated script
- Fix shellcheck SC2124 in the generated script
- Hide flag completion unless input ends with a hyphen


v0.4.3 - 2022-07-14
----------------------------------------

- Fix file/folder completion when they contain spaces


v0.4.2 - 2022-05-27
----------------------------------------

- Allow keeping the test script with --keep


v0.4.1 - 2022-05-21
----------------------------------------

- Remove support for arbitrary script test to fix zsh incompatibilities


v0.4.0 - 2022-05-21
----------------------------------------

- Improve template
- Refactor CLI commands
- Add Tester class for testing any completions script
- Add tester CLI command
- Add support for middle wildcard for --flag args completions
- Add COMPLETELY_DEBUG environment setting
- Allow setting the CONFIG_PATH argument via the COMPLETELY_CONFIG_PATH environment variable
- Allow setting the SCRIPT_PATH argument via the COMPLETELY_SCRIPT_PATH environment variable


v0.3.1 - 2022-02-20
----------------------------------------

- Fix Psych 4 errors for Ruby 3.1


v0.3.0 - 2022-01-28
----------------------------------------

- Fix generated script for zsh compatibility


v0.2.0 - 2021-09-03
----------------------------------------

- Improve generated code to support local completions


v0.1.3 - 2021-07-21
----------------------------------------

- Fix function name when only spaced patterns are configured


v0.1.2 - 2021-07-20
----------------------------------------

- Add ability to generate a function that prints the script


v0.1.1 - 2021-07-20
----------------------------------------

- Fix missing VERSION error


v0.1.0 - 2021-07-20
----------------------------------------

- Initial version


