(require 'package)
(add-to-list 'package-archives
         '("melpa" . "http://melpa.org/packages/"))

;; Use CMD as META
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

;; Don't force double-space for sentence detection
(setq sentence-end-double-space nil)

;; Let Emacs put customizations into a separate file
(let ((my-custom-file (locate-user-emacs-file "custom.el")))
  (setq custom-file my-custom-file)
  (load custom-file 'no-error))

;; Don't download stuff from MELPA by default -> prefer the
;; Nix-installed ones
(require 'use-package-ensure)
(setq use-package-always-ensure nil)

;;; LaTeX

(load "auctex.el" nil t t)

;; FIXME: set to local path to howto repository
(setenv "TEXINPUTS" (concat (expand-file-name "~/Desktop/documents/tex") ":"))

(add-hook 'TeX-mode-hook 'auto-fill-mode)
(add-hook 'tex-mode-hook 'auto-fill-mode)

(autoload 'font-latex-setup "font-latex" "font-lock support for LaTeX")

(add-hook 'LaTeX-mode-hook 'font-latex-setup)
(add-hook 'latex-mode-hook 'font-latex-setup)

(setq TeX-parse-self t)

(setq TeX-view-program-selection '((output-pdf "PDF Viewer")))
(setq TeX-view-program-list
      '(("PDF Viewer" "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")))

(setq TeX-source-correlate-method 'synctex
      TeX-source-correlate-mode t
      TeX-source-correlate-start-server t)

;;; org-mode

(require 'org-loaddefs)
;; The following lines are always needed.  Choose your own keys.
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-cr" (lambda () (interactive) (org-capture nil "t")))

;; FIXME: adapt to your personal file paths here
(setq org-log-done 'time
      org-read-date-popup-calendar nil
      org-refile-use-outline-path t
      org-refile-targets '((nil . (:maxlevel . 3)))
      org-agenda-files '("~/Desktop/todos.org")
      org-directory "~/data/org"
      org-default-notes-file (concat org-directory "/Desktop/todos.org")
      org-remember-default-headline "Inbox"
      org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Desktop/todos.org" "Inbox")
	     "* TODO %?\n  %i\n  %a"))
      org-outline-path-complete-in-steps nil) ; for Helm
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'auto-fill-mode)

(setq org-todo-keywords
  '((sequence "TODO" "IN PROGRESS" "FEEDBACK" "|" "DONE" "DELEGATED")))

;;; ledger-mode

(setq ledger-highlight-xact-under-point nil)
(add-to-list 'auto-mode-alist '("\\.journal\\'" . ledger-mode))
(setq ledger-mode-should-check-version nil)

;;; Line numbers

(global-display-line-numbers-mode)

;;; Incremental narrowing and friends

(use-package rg)

(use-package which-key
  :init (which-key-mode))

;; cf emacs-vertico
(use-package vertico
  :init (vertico-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element)
  )

(use-package marginalia
  :init (marginalia-mode))

;;; Use a nice, dark theme
(load-theme 'wombat)

;; Easier switching of themes.  Use M-x switch-theme
(defun available-themes ()
  "Get a list of the names of all available themes, excluding the
currently enabled one(s)."
  (mapcar #'symbol-name
          (seq-difference (custom-available-themes)
                          custom-enabled-themes)))

(defun switch-theme (name)
  "Switch themes interactively.  Similar to `load-theme' but also
disables all other enabled themes."
  (interactive
   (list (intern
          (completing-read
           "Theme: "
           (available-themes)))))
  (progn
    (mapc #'disable-theme
          custom-enabled-themes)
    (princ name)
    (load-theme name t)))

;;; Work around some issues with PATH on macOS.  You might want to
;;; disable this on
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;;; Magit
(use-package magit
  :defer t)
