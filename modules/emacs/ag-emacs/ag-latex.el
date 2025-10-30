(load "auctex.el" nil t t)

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

(defun ag/TeX-guillemets ()
  "When typing, replace opening and closing quotes with guillemets."
  (interactive)
  (setq TeX-open-quote "\"<")
  (setq TeX-close-quote "\">"))

(defun ag/TeX-german-quotes ()
  "When typing, replace opening and closing quotes with German
quotes."
  (interactive)
  (setq TeX-open-quote "\"`")
  (setq TeX-close-quote "\"'"))

(defun ag/TeX-english-quotes ()
  "When typing, replace opening and closing quotes with English
quotes."
  (interactive)
  (setq TeX-open-quote "``")
  (setq TeX-close-quote "''"))

(provide 'ag-latex)
