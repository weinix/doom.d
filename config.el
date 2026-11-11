;;; config.el -*- lexical-binding: t; -*-
;; GENERATED from config.org by Doom's :config literate module. Do not edit.

(setq doom-theme 'zaiste)
(setq display-line-numbers-type 't)

(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 18 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Noto Serif" :size 13))
(setq doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 28 :weight 'light))

(use-package! rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(setq explicit-shell-file-name "/bin/zsh"
      shell-file-name "zsh")

(setq projectile-project-search-path '("~/workspace/"))

(setq dired-dwim-target t)

(setq org-directory "~/workspace/org/")
(after! org
  (setq org-agenda-files '("~/gtd" "~/workspace/org/")))

(use-package! org-gtd
  :after org
  :init
  (setq org-gtd-update-ack "4.0.0")
  :config
  (setq org-edna-use-inheritance t)
  (org-edna-mode)
  (map! :leader
        (:prefix ("d" . "org-gtd")
         :desc "Capture"        "c" #'org-gtd-capture
         :desc "Engage"         "e" #'org-gtd-engage
         :desc "Process inbox"  "p" #'org-gtd-process-inbox
         :desc "Show all next"  "n" #'org-gtd-show-all-next
         :desc "Stuck projects" "s" #'org-gtd-review-stuck-projects))
  (map! :map org-gtd-clarify-map
        :desc "Organize this item" "C-c c" #'org-gtd-organize))

(custom-set-faces!
  '(org-document-title :height 1.6 :weight bold)
  '(org-level-1 :inherit outline-1 :height 1.35)
  '(org-level-2 :inherit outline-2 :height 1.25)
  '(org-level-3 :inherit outline-3 :height 1.15)
  '(org-level-4 :inherit outline-4 :height 1.08)
  '(org-level-5 :inherit outline-5 :height 1.0))

(after! org-modern
  (setq org-modern-hide-stars nil
        org-modern-star 'replace
        org-modern-table nil))

(add-hook 'org-mode-hook #'mixed-pitch-mode)

(after! org
  (setq org-log-done 'time
        org-ellipsis " ▾ "
        org-startup-with-inline-images t
        org-image-actual-width '(600))
  (add-to-list 'org-capture-templates
               '(
                 "j" "Journal" entry
                 (file+olp+datetree "journal.org")
                 "* %U %?\n%i" :prepend t :kill-buffer t)))

(set-popup-rule! "^\\*Org Agenda" :side 'bottom :size 0.90 :select t :ttl nil)
(set-popup-rule! "^CAPTURE.*\\.org$" :side 'bottom :size 0.90 :select t :ttl nil)

(use-package! org-super-agenda
  :after org-agenda
  :config
  (setq org-super-agenda-groups
        '((:name "Today"      :time-grid t :scheduled today)
          (:name "Due today"  :deadline today)
          (:name "Important"  :priority "A")
          (:name "Overdue"    :deadline past)
          (:name "Due soon"   :deadline future)))
  (org-super-agenda-mode 1))

(after! ox
  (require 'ox-koma-letter))

(after! tramp
  (setq tramp-default-method "sshx")
  (add-to-list 'tramp-remote-process-environment "QUOTING_STYLE=literal"))

(let ((local (expand-file-name "config.local.el" doom-user-dir)))
  (when (file-exists-p local)
    (load local)))

;; Kitty graphics + Evil in `emacs -nw'.
;;
;; Graphics setup must run after kkp's async Kitty Keyboard Protocol handshake
;; on `tty-setup-hook' (kitty-graphics.el issue #33); otherwise partial kkp setup
;; breaks modifiers and motion keys session-wide.
(defun my/kitty-graphics-refresh-org-previews ()
  "Re-run Org link previews after kitty-graphics becomes active.
Startup `#+STARTUP: linkpreviews' can run before `kitty-graphics-setup',
which leaves previews empty in `emacs -nw' even though PNGs exist."
  (when (and kitty-graphics-mode (not (display-graphic-p)))
    (dolist (buf (buffer-list))
      (when (and (buffer-live-p buf)
                 (with-current-buffer buf (derived-mode-p 'org-mode)))
        (with-current-buffer buf
          (ignore-errors (org-link-preview-refresh)))))))

(defun my/kitty-graphics-setup-safe ()
  (unless (bound-and-true-p my/kitty-graphics-setup-done)
    (setq my/kitty-graphics-setup-done t)
    (require 'kitty-graphics)
    (kitty-graphics-setup)
    (run-with-idle-timer 0.5 nil #'my/kitty-graphics-refresh-org-previews)
    (unless (or (display-graphic-p) kitty-graphics-mode)
      (message "kitty-graphics: mode is OFF (no inline images). Run M-x kitty-graphics-doctor — over SSH use `kitten ssh` or export Kitty env (KITTY_WINDOW_ID)."))))

(with-eval-after-load 'kkp
  (add-hook 'kkp-terminal-setup-complete-hook #'my/kitty-graphics-setup-safe))

;; Fallback when kkp never completes (slow SSH, probing timeout).
(run-with-idle-timer
 2 nil
 (lambda ()
   (unless (bound-and-true-p my/kitty-graphics-setup-done)
     (my/kitty-graphics-setup-safe))))

(use-package! kitty-graphics
  :if (not (display-graphic-p))
  :defer t)

;; Org 9.8+ passes REFRESH as a 2nd arg to `org-display-inline-images'; stock
;; kitty-graphics advice applies all args to a 3-arg TTY helper (arity error).
(after! kitty-graphics
  ;; Herdr panes do not expose KITTY_* env, but Herdr forwards Kitty graphics
  ;; escapes from pane apps to the outer Kitty terminal (see herdr terminal.kitty_graphics).
  (defun my/inside-herdr-pane-p (&optional frame)
    (when-let* ((frame (or frame (selected-frame)))
                (val (kitty-graphics--frame-getenv "HERDR_ENV" frame)))
      (member val '("1" "true" "yes" "on"))))
  (defadvice! my/kitty-graphics-detect-herdr-a (fn)
    :around #'kitty-graphics--kitty-detect
    (or (my/inside-herdr-pane-p) (funcall fn)))
  (defun kitty-graphics--org-display-advice (orig-fn &rest args)
    (if (and kitty-graphics-mode (not (display-graphic-p)))
        (let* ((include-linked (nth 0 args))
               (refresh (nth 1 args))
               (beg (nth 2 args))
               (end (nth 3 args)))
          (when refresh
            (kitty-graphics-remove-images beg end))
          (kitty-graphics--org-display-inline-images-tty include-linked beg end))
      (apply orig-fn args)))
  ;; Org 10 + `#+STARTUP: linkpreviews' uses `org-link-preview-region', not
  ;; `org-display-inline-images'.  Stock advice ignored REFRESH and could leave
  ;; stale overlays after `C-c C-c'.
  (defun kitty-graphics--org-link-preview-region-advice (orig-fn &optional include-linked refresh beg end)
    (if (and kitty-graphics-mode (not (display-graphic-p)))
        (progn
          (when refresh
            (kitty-graphics-remove-images beg end))
          (kitty-graphics--org-display-inline-images-tty include-linked beg end))
      (funcall orig-fn include-linked refresh beg end))))

;; kitty-graphics replaces `image-mode' with `kitty-graphics-image-mode' and
;; uses `special-mode-map'; evil-collection does not cover either mode, so Evil
;; stays in emacs state and h/j/k/l stop working until you force normal state.
(after! evil
  (evil-set-initial-state 'kitty-graphics-image-mode 'normal)
  (evil-set-initial-state 'kitty-graphics-browser-mode 'normal))

(after! org
  ;; Enable Graphviz DOT and PlantUML execution.
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((dot . t)
     (plantuml . t)))

  ;; Use the installed PlantUML executable.
  (setq org-plantuml-exec-mode 'plantuml
        org-plantuml-executable-path
        (or (executable-find "plantuml") "plantuml"))

  ;; Don't ask before evaluating diagram blocks (they only render images).
  (setq org-confirm-babel-evaluate
        (lambda (lang _body) (not (member lang '("dot" "plantuml")))))

  ;; Keep diagram output reasonably sized.
  (setq org-image-actual-width 500)

  ;; Doom calls obsolete `org-display-inline-images' after babel; on a tty that
  ;; function is a no-op unless kitty-graphics intercepts.  Org 10 uses link
  ;; previews (`diagram.org' has `#+STARTUP: linkpreviews').
  (defadvice! my/org-babel-refresh-diagram-previews-a
      (:override +org-redisplay-inline-images-in-babel-result-h)
    (unless (or (bound-and-true-p org-export-current-backend)
                (string-match-p "^ \\*temp" (buffer-name)))
      (save-excursion
        (when-let* ((beg (org-babel-where-is-src-block-result))
                    (end (progn (goto-char beg) (forward-line) (org-babel-result-end))))
          (org-link-preview-region nil t (min beg end) (max beg end)))))))
