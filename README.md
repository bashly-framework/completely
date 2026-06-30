# Completely - Bash Completions Generator

![repocard](https://repocard.dannyben.com/svg/completely.svg)

Completely is a command line utility and a Ruby library that lets you generate
bash completion scripts from simple YAML configuration.

This tool is for you if:

1. You develop your own command line tools.
2. Your life feels empty without bash completions.
3. Bash completion scripts seem overly complex to you.

Note that if you are building bash command line scripts with [bashly][bashly],
then this functionality is already integrated with it.

---


## Install

```bash
$ gem install completely
```

or with homebrew:

```bash
$ brew install brew-gem
$ brew gem install completely
```

or with Docker:

```bash
$ alias completely='docker run --rm -it --user $(id -u):$(id -g) --volume "$PWD:/app" dannyben/completely'
```


## Configuration syntax

Completely works with a YAML configuration file as input, and generates a bash
completions script as output.

There are three configuration formats:

- **Pattern config**: Recommended for new projects. It describes command shapes,
  option groups, and value sources explicitly.
- **Flat config**: The original simple pattern-to-suggestions format.
- **Nested config**: A nested spelling of the flat config format.

You can save a sample YAML file by running:

```bash
$ completely init
```

This creates a `completely.yaml` file using the recommended pattern config
format. You can also choose a format explicitly:

```bash
$ completely init --format pattern
$ completely init --format flat
$ completely init --format nested
```

To generate the bash script, run:

```bash
$ completely generate

# or, to preview it without saving:
$ completely preview
```

For more options, run:

```bash
$ completely --help
```

### Pattern config

Pattern config is the recommended format for new completion files.

```yaml
patterns:
  - mygit [root options]
  - mygit init [init options] <directory>
  - mygit status [status options]

options:
  root:
    - -h|--help
    - -v|--version
  init:
    - --bare
  status:
    - --help
    - --branch|-b <branch>
    - --format <format>
    - --verbose (repeatable)

tokens:
  directory: +directory
  branch: $(git branch --format='%(refname:short)' 2>/dev/null)
  format: [short, long]
```

The `patterns` section describes valid command shapes:

- Plain words are command words, for example `mygit`, `init`, and `status`.
- Command aliases can be written with `|`, for example `status|st`.
- `[name options]` references `options.name`. `[name]` is also accepted.
- `<token>` references `tokens.token`.
- `<token>...` marks the final positional as repeatable.

The `options` section defines option groups:

```yaml
options:
  status:
    - --help
    - --branch|-b <branch>
    - --verbose (repeatable)
```

An option can be a plain flag, aliases separated with `|`, or a flag that
expects a value token.

Options are unique by default. If an option should be suggested again after it
was already used, add `(repeatable)`:

```yaml
options:
  status:
    - --tag <tag> (repeatable)
```

The final positional in a pattern can be repeatable:

```yaml
patterns:
  - mygit upload <file>...
```

Only the final positional may be repeatable.

The `tokens` section defines completion sources. Each token value can be one of
these forms:

```yaml
tokens:
  source: ~
  directory: +directory
  branch: $(git branch --format='%(refname:short)' 2>/dev/null)
  format: [short, long]
  target: [+file, +directory, README.md, $(git branch --format='%(refname:short)' 2>/dev/null)]
  literal: ++file
```

- A null value such as `~` defines a token without completion suggestions.
- A value starting with `+`, such as `+directory`, uses a bash built-in completion action.
- A value starting with `++`, such as `++file`, provides the literal completion word `+file`.
- Plain strings, including `$(...)` command substitutions, are added to the completion word list.
- An array combines multiple source items.

Every `[name]` option group and every `<token>` used by patterns or options must
be defined. This keeps typos from generating broken completion scripts.

### Flat config

Flat config is the original Completely format. It is simpler, and remains
supported.

```yaml
mygit:
- -h
- -v
- --help
- --version
- init
- status

mygit init:
- --bare
- <directory>

mygit status:
- --help
- --verbose
- --branch
- -b

mygit status*--branch: &branches
- $(git branch --format='%(refname:short)' 2>/dev/null)

mygit status*-b: *branches
```

Each pattern is checked against the user's input. If the input matches the
pattern, the list that follows it is suggested as completions.

Suggested completions do not show flags (strings that start with a hyphen `-`)
unless the input ends with a hyphen.

Adding a `*` wildcard in the middle of a pattern can be used for suggesting flag
arguments. In the example above, branches are suggested after `--branch` or `-b`.

### Nested config

Nested config is an alternate spelling of flat config. It generates the same
completion behavior as the flat example above.

```yaml
mygit:
- -h
- -v
- --help
- --version
- init:
  - --bare
  - <directory>
- status:
  - --help
  - --verbose
  - +--branch: &branches
    - $(git branch --format='%(refname:short)' 2>/dev/null)
  - +-b: *branches
```

The rules are:

- Each pattern can have a mixed array of strings and hashes.
- Strings and hash keys are used as completion strings for that pattern.
- Hashes can contain a nested mixed array of the same structure.
- Hash keys are appended to the parent prefix. In the example above, the `init`
  hash creates the pattern `mygit init`.
- To provide a wildcard such as `mygit status*--branch`, prefix the hash key with
  `+` or `*`, for example `+--branch` or `"*--branch"`. When using `*`, quote the
  key because asterisks have special meaning in YAML.

### Completion sources

Pattern config and the original flat/nested formats use the same underlying bash
completion sources, but they spell built-ins differently.

Pattern config uses named tokens:

```yaml
tokens:
  file: +file
  directory: +directory
  branch: $(git branch --format='%(refname:short)' 2>/dev/null)
  format: [short, long]
```

Flat and nested configs use completion words directly:

```yaml
mygit init:
- <file>
- <directory>
- $(git branch --format='%(refname:short)' 2>/dev/null)
```

The built-in names map to `compgen -A` actions:

| Built-in      | Meaning
|---------------|---------------------
| `alias`       | Alias names
| `arrayvar`    | Array variable names
| `binding`     | Readline key binding names
| `builtin`     | Names of shell builtin commands
| `command`     | Command names
| `directory`   | Directory names
| `disabled`    | Names of disabled shell builtins
| `enabled`     | Names of enabled shell builtins
| `export`      | Names of exported shell variables
| `file`        | File names
| `function`    | Names of shell functions
| `group`       | Group names
| `helptopic`   | Help topics as accepted by the help builtin
| `hostname`    | Hostnames, as taken from the file specified by the HOSTFILE shell variable
| `job`         | Job names
| `keyword`     | Shell reserved words
| `running`     | Names of running jobs
| `service`     | Service names
| `signal`      | Signal names
| `stopped`     | Names of stopped jobs
| `user`        | User names
| `variable`    | Names of all shell variables

### Completion scope and limitations

- Completion words are treated as whitespace-delimited tokens.
- Literal completion phrases that contain spaces are not supported as a single completion item.
- Quotes and other special shell characters in literal completion words are not escaped automatically.
- Dynamic `$(...)` completion commands should output plain whitespace-delimited words.


## Using the generated completion scripts

In order to enable the completions, simply source the generated script:

```bash
$ source completely.bash
```

If you are satisfied with the result, and wish to copy the script to your bash
completions directory, simply run:

```bash
$ completely install
```

Alternatively, you can copy the script manually to one of these directories
(whichever exists):

- `/usr/share/bash-completion/completions`
- `/usr/local/etc/bash_completion.d`
- `~/.local/share/bash-completion/completions`


## Testing and debugging completion scripts

You can use the built in completions script tester by running `completely test`.

This command lets you test completions for your completions script.

In addition, you can set the `COMPLETELY_DEBUG` environment variable to any value
in order to generate scripts with some additional debugging functionality. Run
`completely generate --help` for additional information.


## Using from within Ruby code

```ruby
require 'completely'

# Load from file
completions = Completely::Completions.load "input.yaml"

# Or, from a pattern config hash
input = {
  "patterns" => [
    "mygit init [init options] <directory>",
    "mygit status|st [status options]"
  ],
  "options" => {
    "init" => ["--bare"],
    "status" => ["--verbose|-v", "--branch|-b <branch>"]
  },
  "tokens" => {
    "directory" => "directory",
    "branch" => "$(git branch --format='%(refname:short)' 2>/dev/null)"
  }
}
completions = Completely::Completions.new input

# Flat and nested config hashes are also supported by the same API.
input = {
  "mygit" => %w[--help --version status init],
  "mygit status" => %w[--help --verbose --branch]
}
completions = Completely::Completions.new input

# Generate the script
puts completions.script

# Or, generate a function that echos the script
puts completions.wrapper_function
puts completions.wrapper_function "custom_function_name"

# Or, test the completions with the Tester object
p completions.tester.test "mygit status "
```


## Completions in ZSH

If you are using Oh-My-Zsh, bash completions should already be enabled,
otherwise, you should enable completion by adding this to your `~/.zshrc`
(if is it not already there):

```bash
# Load completion functions
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
```

## Customizing the `complete` command

In case you wish to customize the `complete` command call in the generated
script, you can do so by adding any additional flags to the
`completely.yaml` configuration file using the special `completely_options`
key. Completely passes these options to Bash's `complete` command as is. For
example:

```yaml
completely_options:
  complete_options: -o nosort
```

## Contributing / Support

If you experience any issue, have a question or a suggestion, or if you wish
to contribute, feel free to [open an issue][issues].

---

[issues]: https://github.com/bashly-framework/completely/issues
[compgen]: https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html
[bashly]: https://bashly.dannyb.co/
