;; Use CMD as META
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

;;; Work around some issues with PATH on macOS. FIXME(Johannes/Mike): test this
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(provide 'ag-macos)
