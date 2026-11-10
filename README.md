# doom.d

A literate [Doom Emacs](https://github.com/doomemacs/doomemacs) config.

- `config.org`: the config, with notes. Doom's `:config literate` module tangles
  it into `config.el` when you save it and before every `doom sync`.
- `config.el`: generated, but committed so a fresh clone works before anything
  has been tangled. Don't edit it by hand.
- `init.el` / `packages.el`: the module list and extra packages, kept as plain
  elisp because Doom reads them before `config.org` is tangled.
- `themes/`: the light `zaiste` theme.

## Install

```sh
git clone https://github.com/weinix/doom.d ~/.config/doom
~/.config/emacs/bin/doom sync
```

Put your name, email and per-machine tweaks in `~/.config/doom/config.local.el`.
It is gitignored and loads last:

```elisp
(setq user-full-name "Your Name"
      user-mail-address "you@example.com")
```
