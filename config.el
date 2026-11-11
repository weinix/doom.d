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
(defun my/kitty-graphics-setup-safe ()
  (unless (bound-and-true-p my/kitty-graphics-setup-done)
    (setq my/kitty-graphics-setup-done t)
    (require 'kitty-graphics)
    (kitty-graphics-setup)))

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
  (setq org-image-actual-width 500))
