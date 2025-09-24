Changelog
========================================

v0.7.3 - 2025-09-24
----------------------------------------

- Add support for reading config from stdin and writing to stdout [`764fb36`](https://github.com/bashly-framework/completely/commit/764fb36)
- Fix repeating final completion [`0029c4e`](https://github.com/bashly-framework/completely/commit/0029c4e)
- Refactor installer with new io / string builders [`cb91679`](https://github.com/bashly-framework/completely/commit/cb91679)
- Add support for `generate --install` [`c5a877e`](https://github.com/bashly-framework/completely/commit/c5a877e)
- Compare [`v0.7.2..v0.7.3`](https://github.com/bashly-framework/completely/compare/v0.7.2..v0.7.3)


v0.7.2 - 2025-08-04
----------------------------------------

- Fix JSON schema [`3cc3ef6`](https://github.com/bashly-framework/completely/commit/3cc3ef6)
- Drop support for Ruby 3.0 and 3.1 [`7ff8bd8`](https://github.com/bashly-framework/completely/commit/7ff8bd8)
- Compare [`v0.7.1..v0.7.2`](https://github.com/bashly-framework/completely/compare/v0.7.1..v0.7.2)


v0.7.1 - 2025-04-04
----------------------------------------

- Add support for modifying the `complete` command options [`690c264`](https://github.com/bashly-framework/completely/commit/690c264)
- Compare [`v0.7.0..v0.7.1`](https://github.com/bashly-framework/completely/compare/v0.7.0..v0.7.1)


v0.7.0 - 2024-11-29
----------------------------------------

- Update instructions and template for obtaining list of git branches [`8cdfabd`](https://github.com/bashly-framework/completely/commit/8cdfabd)
- Add support for nested configuration [`742e3cd`](https://github.com/bashly-framework/completely/commit/742e3cd)
- Add `completely init --nested` and explain nested syntax in the README [`f1e17ed`](https://github.com/bashly-framework/completely/commit/f1e17ed)
- Compare [`v0.6.3..v0.7.0`](https://github.com/bashly-framework/completely/compare/v0.6.3..v0.7.0)


v0.6.3 - 2024-07-05
----------------------------------------

- Allow using colon, semicolon and equal sign in completions [`a9e6a6e`](https://github.com/bashly-framework/completely/commit/a9e6a6e)
- Check output with shfmt [`3f7ae7e`](https://github.com/bashly-framework/completely/commit/3f7ae7e)
- Revert wordbreak (colon) patch [`24f9d3d`](https://github.com/bashly-framework/completely/commit/24f9d3d)
- Compare [`v0.6.2..v0.6.3`](https://github.com/bashly-framework/completely/compare/v0.6.2..v0.6.3)


v0.6.2 - 2024-02-08
----------------------------------------

- Update possible completions installation directories [`2bc93a7`](https://github.com/bashly-framework/completely/commit/2bc93a7)
- Build docker images automatically [`4d20dfd`](https://github.com/bashly-framework/completely/commit/4d20dfd)
- Compare [`v0.6.1..v0.6.2`](https://github.com/bashly-framework/completely/compare/v0.6.1..v0.6.2)


v0.6.1 - 2023-06-23
----------------------------------------

- Add ability to uninstall a completion script [`67b6715`](https://github.com/bashly-framework/completely/commit/67b6715)
- Compare [`v0.6.0..v0.6.1`](https://github.com/bashly-framework/completely/compare/v0.6.0..v0.6.1)


v0.6.0 - 2023-06-23
----------------------------------------

- Refactor install command and add an Installer model [`b1341fa`](https://github.com/bashly-framework/completely/commit/b1341fa)
- Drop support for Ruby 2.7 [`151eff1`](https://github.com/bashly-framework/completely/commit/151eff1)
- Change exception classes [`3ce16ac`](https://github.com/bashly-framework/completely/commit/3ce16ac)
- Compare [`v0.5.4..v0.6.0`](https://github.com/bashly-framework/completely/compare/v0.5.4..v0.6.0)


v0.5.4 - 2023-04-21
----------------------------------------

- Add `completely install` command [`2fbd879`](https://github.com/bashly-framework/completely/commit/2fbd879)
- Compare [`v0.5.3..v0.5.4`](https://github.com/bashly-framework/completely/compare/v0.5.3..v0.5.4)


v0.5.3 - 2023-01-31
----------------------------------------

- Upgrade dependencies [`211166a`](https://github.com/bashly-framework/completely/commit/211166a)
- Compare [`v0.5.2..v0.5.3`](https://github.com/bashly-framework/completely/compare/v0.5.2..v0.5.3)


v0.5.2 - 2022-12-02
----------------------------------------

- Improve test command output and allow multiple complines in one run [`e924571`](https://github.com/bashly-framework/completely/commit/e924571)
- Compare [`v0.5.1..v0.5.2`](https://github.com/bashly-framework/completely/compare/v0.5.1..v0.5.2)


v0.5.1 - 2022-11-28
----------------------------------------

- Refactor with rubocop [`42b996d`](https://github.com/bashly-framework/completely/commit/42b996d)
- Fix broken script when wildcards follow the first word [`63b77d1`](https://github.com/bashly-framework/completely/commit/63b77d1)
- Show warning when running the test command on an invalid file [`de7ede0`](https://github.com/bashly-framework/completely/commit/de7ede0)
- Compare [`v0.5.0..v0.5.1`](https://github.com/bashly-framework/completely/compare/v0.5.0..v0.5.1)


v0.5.0 - 2022-09-04
----------------------------------------

- Add docker release [`39acd6e`](https://github.com/bashly-framework/completely/commit/39acd6e)
- Fix shellcheck SC2162 in the generated script [`9e703ec`](https://github.com/bashly-framework/completely/commit/9e703ec)
- Fix shellcheck SC2124 in the generated script [`2d23c51`](https://github.com/bashly-framework/completely/commit/2d23c51)
- Hide flag completion unless input ends with a hyphen [`c15d705`](https://github.com/bashly-framework/completely/commit/c15d705)
- Compare [`v0.4.3..v0.5.0`](https://github.com/bashly-framework/completely/compare/v0.4.3..v0.5.0)


v0.4.3 - 2022-07-14
----------------------------------------

- Fix file/folder completion when they contain spaces [`9dea691`](https://github.com/bashly-framework/completely/commit/9dea691)
- Compare [`v0.4.2..v0.4.3`](https://github.com/bashly-framework/completely/compare/v0.4.2..v0.4.3)


v0.4.2 - 2022-05-27
----------------------------------------

- Allow keeping the test script with --keep [`20d9b15`](https://github.com/bashly-framework/completely/commit/20d9b15)
- Compare [`v0.4.1..v0.4.2`](https://github.com/bashly-framework/completely/compare/v0.4.1..v0.4.2)


v0.4.1 - 2022-05-21
----------------------------------------

- Remove support for arbitrary script test to fix zsh incompatibilities [`9e3e6d9`](https://github.com/bashly-framework/completely/commit/9e3e6d9)
- Compare [`v0.4.0..v0.4.1`](https://github.com/bashly-framework/completely/compare/v0.4.0..v0.4.1)


v0.4.0 - 2022-05-21
----------------------------------------

- Improve template [`8172be2`](https://github.com/bashly-framework/completely/commit/8172be2)
- Refactor CLI commands [`1fced36`](https://github.com/bashly-framework/completely/commit/1fced36)
- Add Tester class for testing any completions script [`986f4d1`](https://github.com/bashly-framework/completely/commit/986f4d1)
- Add tester CLI command [`09e91ee`](https://github.com/bashly-framework/completely/commit/09e91ee)
- Add support for middle wildcard for --flag args completions [`8d25207`](https://github.com/bashly-framework/completely/commit/8d25207)
- Add COMPLETELY_DEBUG environment setting [`44c00a1`](https://github.com/bashly-framework/completely/commit/44c00a1)
- Allow setting the CONFIG_PATH argument via the COMPLETELY_CONFIG_PATH environment variable [`8ef65e1`](https://github.com/bashly-framework/completely/commit/8ef65e1)
- Allow setting the SCRIPT_PATH argument via the COMPLETELY_SCRIPT_PATH environment variable [`a484ff4`](https://github.com/bashly-framework/completely/commit/a484ff4)
- Compare [`v0.3.1..v0.4.0`](https://github.com/bashly-framework/completely/compare/v0.3.1..v0.4.0)


v0.3.1 - 2022-02-20
----------------------------------------

- Fix Psych 4 errors for Ruby 3.1 [`2fb9a73`](https://github.com/bashly-framework/completely/commit/2fb9a73)
- Compare [`v0.3.0..v0.3.1`](https://github.com/bashly-framework/completely/compare/v0.3.0..v0.3.1)


v0.3.0 - 2022-01-28
----------------------------------------

- Fix generated script for zsh compatibility [`d19369b`](https://github.com/bashly-framework/completely/commit/d19369b)
- Compare [`v0.2.0..v0.3.0`](https://github.com/bashly-framework/completely/compare/v0.2.0..v0.3.0)


v0.2.0 - 2021-09-03
----------------------------------------

- Improve generated code to support local completions [`3518434`](https://github.com/bashly-framework/completely/commit/3518434)
- Compare [`v0.1.3..v0.2.0`](https://github.com/bashly-framework/completely/compare/v0.1.3..v0.2.0)


v0.1.3 - 2021-07-21
----------------------------------------

- Fix function name when only spaced patterns are configured [`2e14ec2`](https://github.com/bashly-framework/completely/commit/2e14ec2)
- Compare [`v0.1.2..v0.1.3`](https://github.com/bashly-framework/completely/compare/v0.1.2..v0.1.3)


v0.1.2 - 2021-07-20
----------------------------------------

- Add ability to generate a function that prints the script [`22de124`](https://github.com/bashly-framework/completely/commit/22de124)
- Compare [`v0.1.1..v0.1.2`](https://github.com/bashly-framework/completely/compare/v0.1.1..v0.1.2)


v0.1.1 - 2021-07-20
----------------------------------------

- Fix missing VERSION error [`e6f0ac1`](https://github.com/bashly-framework/completely/commit/e6f0ac1)
- Compare [`v0.1.0..v0.1.1`](https://github.com/bashly-framework/completely/compare/v0.1.0..v0.1.1)


v0.1.0 - 2021-07-20
----------------------------------------

- Initial version [`bcd598c`](https://github.com/bashly-framework/completely/commit/bcd598c)
- Compare [`v0.1.0`](https://github.com/bashly-framework/completely/compare/v0.1.0)


