# Homebrew tap for benn-herrera/tap

- [kbase](https://github.com/benn-herrera/kbase) builds a knowledge base from LaTeX and maintains it
- [laterm](https://github.com/benn-herrera/laterm) is a Claude Code sidecar that renders the active conversation's LaTeX math expressions as inline images in a separate terminal window

## Developer
<https://keyoxide.org/wkd/benn@bennherrera.dev>

## Install

```bash
brew tap benn-herrera/tap
brew install kbase
brew install laterm
```

## Releasing a new version

1. Tag the formula's product source tree (`just dist --tag` does this after a complete dist build).
2. Point formula's `url` at the new tag's source tarball.
3. Replace `sha256` with the value `brew fetch <formula-name>` reports.
