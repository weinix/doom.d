;;; config.el -*- lexical-binding: t; -*-
;; GENERATED from config.org by Doom's :config literate module. Do not edit.

(setq doom-theme 'zaiste)
(setq display-line-numbers-type 'relative)

(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 18 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Noto Serif" :size 13))
(setq doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 28 :weight 'light))

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
               '("j" "Journal" entry
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
