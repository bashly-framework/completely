# Completely Specs

## Running tests

You can run specs with `rspec` as usual.

We recommend using [`respec`][2], which wraps common spec workflows:

```bash
rspec
# or
respec
```

You might need to prefix the commands with `bundle exec`, depending on the way
Ruby is installed.

Useful helper shortcuts:

```bash
# script quality checks (shellcheck + shfmt generated script tests)
respec tagged script_quality

# integration behavior suite
respec only integration
```

## Interactive Approvals

Some tests may prompt you for an interactive approval of changes. This
functionality is provided by the [rspec_approvals gem][1].

Be sure to only approve changes that are indeed expected.


## ZSH Compatibility Test

ZSH compatibility test is done by running the completely tester script inside a
zsh container. This is all done automatically by `spec/completely/zsh_spec.rb`.


[1]: https://github.com/dannyben/rspec_approvals
[2]: https://github.com/DannyBen/respec
