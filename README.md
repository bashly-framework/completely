# Completely - Bash Completions Generator

![repocard](repocard.svg)

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

Completely works with a simple YAML configuration file as input, and generates
a bash completions script as output.

The configuration file is built of blocks that look like this:

```yaml
pattern:
- --argument
- --param
- command
```

Each pattern contains an array of words (or functions) that will be suggested
for the auto complete process.

You can save a sample YAML file by running:

```bash
$ completely init
```

This will generate a file named `completely.yaml` with this content:

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

Each pattern in this configuration file will be checked against the user's
input, and if the input matches the pattern, the list that follows it will be
suggested as completions.

Note that the suggested completions will not show flags (strings that start with 
a hyphen `-`) unless the input ends with a hyphen.

To generate the bash script, simply run:

```bash
$ completely generate

# or, to just preview it without saving:
$ completely preview
```

For more options (like setting input/output path), run:

```bash
$ completely --help
```

### Suggesting files, directories and other bash built-ins

In addition to specifying a simple array of completion words, you may use
the special syntax `<..>` to suggest more advanced functions.

```yaml
pattern:
- <file>
- <directory>
```

These suggestions will add the list of files and directories
(when `<file>` is used) or just directories (when `<directory>` is used) to
the list of suggestions.

You may use any of the below keywords to add additional suggestions:

| Keyword       | Meaning
|---------------|---------------------
| `<alias>`     | Alias names
| `<arrayvar>`  | Array variable names
| `<binding>`   | Readline key binding names
| `<builtin>`   | Names of shell builtin commands
| `<command>`   | Command names
| `<directory>` | Directory names
| `<disabled>`  | Names of disabled shell builtins
| `<enabled>`   | Names of enabled shell builtins
| `<export>`    | Names of exported shell variables
| `<file>`      | File names
| `<function>`  | Names of shell functions
| `<group>`     | Group names
| `<helptopic>` | Help topics as accepted by the help builtin
| `<hostname>`  | Hostnames, as taken from the file specified by the HOSTFILE shell variable
| `<job>`       | Job names
| `<keyword>`   | Shell reserved words
| `<running>`   | Names of running jobs
| `<service>`   | Service names
| `<signal>`    | Signal names
| `<stopped>`   | Names of stopped jobs
| `<user>`      | User names
| `<variable>`  | Names of all shell variables

For those interested in the technical details, any word between `<...>` will
simply be added using the [`compgen -A action`][compgen] function, so you can 
in fact use any of its supported arguments.

### Suggesting custom dynamic suggestions

You can also use any command that outputs a whitespace-delimited list as a
suggestions list, by wrapping it in `$(..)`. For example, in order to add git
branches to your suggestions, use the following:

```yaml
mygit:
- $(git branch --format='%(refname:short)' 2>/dev/null)
```

The `2> /dev/null` is used so that if the command is executed in a directory
without a git repository, it will still behave as expected.

### Suggesting flag arguments

Adding a `*` wildcard in the middle of a pattern can be useful for suggesting
arguments for flags. For example:

```yaml
mygit checkout:
- --branch
- -b

mygit checkout*--branch:
- $(git branch --format='%(refname:short)' 2>/dev/null)

mygit checkout*-b:
- $(git branch --format='%(refname:short)' 2>/dev/null)
```

The above will suggest git branches for commands that end with `-b` or `--branch`.
To avoid code duplication, you may use YAML aliases, so the above can also be
written like this:

```yaml
mygit checkout:
- --branch
- -b

mygit checkout*--branch: &branches
- $(git branch --format='%(refname:short)' 2>/dev/null)

mygit checkout*-b: *branches
```

### Alternative nested syntax

Completely also supports an alternative nested syntax. You can generate this
example by running:

```bash
$ completely init --nested
```

The example configuration below will generate the exact same script as the one
shown at the beginning of this document.

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

The rules here are as follows:

- Each pattern (e.g., `mygit`) can have a mixed array of strings and hashes.
- Strings and hash keys (e.e., `--help` and `init` respectively) will be used
  as completion strings for that pattern.
- Hashes may contain a nested mixed array of the same structure.
- When a hash is provided, the hash key will be appended to the parent prefix.
  In the example above, the `init` hash will create the pattern `mygit init`.
- In order to provide a wildcard (like `mygit status*--branch` in the standard
  configuration syntax), you can provide either a `*` or a `+` prefix to the
  hash key (e.g., `+--branch` or `"*--branch"`). Note that when using a `*`, 
  the hash key must be quoted since asterisks have special meaning in YAML.


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

# Or, from a hash
input = {
  "mygit" => %w[--help --version status init commit],
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
script, you can do so by adding any additional flags to the `completely.yaml`
configuration file using the special `completely_options` key. For example:

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
