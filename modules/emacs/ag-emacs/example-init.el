;; Start the Emacs server: this is necessary to be able to use 'emacsclient'
(server-start)


;; Add our AG "libraries" to Emacs' `load-path'
(add-to-list 'load-path (expand-file-name "~/.config/ag-emacs"))


;;; Load (only) the things you want/need:

;; macOS-specific base configuration
(require 'ag-macos)

;; Common/base setup: completion, magit, grep etc.
(require 'ag-common)

;; Specific technologies that not everyone might need
(require 'ag-latex)
(require 'ag-ledger)


;;; Examples for custom code that would go into this file:

;; Use a nice, dark theme
(load-theme 'wombat)

;; Session restore after restart
(desktop-save-mode)

;; Switch window with Control-TAB
(global-set-key [C-tab] 'other-window)
