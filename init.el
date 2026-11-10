;;; init.el -*- lexical-binding: t; -*-
;; Plain elisp on purpose: Doom loads init.el before config.org is tangled.
;; Run `doom sync` after changing this file.

(doom! :input
       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       dashboard
       hl-todo
       modeline
       nav-flash
       ophints
       (popup +defaults)
       vc-gutter
       window-select
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets
       word-wrap

       :emacs
       (dired +dirvish +icons)
       electric
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       spell

       :tools
       (eval +overlay)
       (lookup +docsets)
       lsp
       magit
       upload

       :lang
       emacs-lisp
       json
       (javascript +lsp)
       markdown
       (org +pretty +pandoc +present +dragndrop)   ; +dragndrop: org-download, SPC m a c/p
       (python +lsp +pyright)
       (sh +lsp)
       yaml

       :os
       (tty +osc)                       ; OSC-52 clipboard in terminal (SSH/tmux)

       :config
       literate                         ; tangle config.org -> config.el on save and sync
       (default +bindings +smartparens))
