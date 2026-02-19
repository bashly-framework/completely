# AGENTS.md

Guidance for coding agents working in this repository.

## Repo Snapshot

- Project: `completely` (Ruby gem that generates Bash completion scripts from YAML).
- Key generation code:
  - `lib/completely/pattern.rb`
  - `lib/completely/templates/template.erb`
- Core behavior tests:
  - `spec/completely/integration_spec.rb`
  - `spec/completely/commands/generate_spec.rb`

## Working Rules

- Keep changes minimal and localized, especially in:
  - completion-word serialization (`Pattern`)
  - generated script runtime behavior (`template.erb`)
- Do not change generated approvals.
- Do not run approval prompts interactively on behalf of the developer.
- If an approval spec changes, stop and ask the developer to review/approve manually.
- Prefer adding regression coverage in integration fixtures for completion behavior changes.

## Fast Validation Loop

Run these first after edits:

```bash
respec tagged script_quality
respec only integration
```

If touching quoting/escaping or dynamic completions, also run:

```bash
respec only pattern
respec only completions
```

## Formatting and Linting Notes

- `shellcheck` and `shfmt` requirements are enforced by specs tagged `:script_quality` in `spec/completely/commands/generate_spec.rb`.
- `shfmt` uses flags:
  - `shfmt -d -i 2 -ci completely.bash`
- Small whitespace differences in heredoc/redirect forms (like `<<<"$x"` vs `<<< "$x"`) can fail shfmt.

## Approval Specs

- Some specs use `rspec_approvals` and may prompt interactively if output changes.
- In non-interactive runs this can fail with `Errno::ENOTTY`.
- Approval decisions are always developer-owned. Agents should not approve/update snapshots.

## Completion Semantics to Preserve

- Literal YAML words with spaces/quotes must complete correctly.
- Dynamic `$(...)` entries must produce multiple completion candidates when command output contains multiple words.
- `<file>`, `<directory>`, and other `<...>` entries map to `compgen -A ...` actions and should remain unaffected by `-W` serialization changes.

## Manual Repro Pattern

Useful local sanity check:

```bash
cd dev
ruby -I../lib ../bin/completely test "cli "
```

Expected: sensible mixed output for dynamic values and quoted/spaced literals.
