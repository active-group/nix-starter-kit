(setq ledger-highlight-xact-under-point nil)
(add-to-list 'auto-mode-alist '("\\.journal\\'" . ledger-mode))
(setq ledger-mode-should-check-version nil)

(provide 'ag-ledger)
