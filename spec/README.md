# Completely Specs

## Running tests

```bash
$ rspec
# or
$ run spec
# or, to run just tests in a given file
$ run spec zsh
# or, to run just specs tagged with :focus
$ run spec :focus
```

You might need to prefix the commands with `bundle exec`, depending on the way
Ruby is installed.

## Interactive Approvals

Some tests may prompt you for an interactive approval of changes. This
functionality is provided by the [rspec_approvals gem][1].

Be sure to only approve changes that are indeed expected.


## ZSH Compatibility Test

ZSH compatibility test is done by running the completely tester script inside a
zsh container. This is all done automatically by `spec/completely/zsh_spec.rb`.


[1]: https://github.com/dannyben/rspec_approvals