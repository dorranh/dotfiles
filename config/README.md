# .config

Local (non-secret) application config. Files with sensitive fields may need to
be manually updated with real values before use.

Simply link the config of interest to $XDG_CONFIG_HOME (generally
`~/.config`).

For example, to add the config for `kitty`:

```sh
mkdir -p $XDG_CONFIG_HOME

ln -s "$(realpath ./kitty)" "$XDG_CONFIG_HOME/kitty"
```
