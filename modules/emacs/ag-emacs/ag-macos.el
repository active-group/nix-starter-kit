;; Use CMD as META
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)

;;; Work around some issues with PATH on macOS. FIXME(Johannes/Mike): test this
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Work around focus issues with frames created by 'emacsclient'
(add-hook 'server-switch-hook
          (lambda nil
            (let ((server-buf (current-buffer)))
              (bury-buffer)
              (switch-to-buffer-other-frame server-buf))))
(add-hook 'server-done-hook 'delete-frame)

(provide 'ag-macos)
