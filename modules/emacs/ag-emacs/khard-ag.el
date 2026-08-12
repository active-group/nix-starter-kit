;;; khard-ag.el --- Display and link to khard contacts              -*- lexical-binding: t; -*-

;;; Commentary:

;; M-x khard-ag-show
;; to select a khard contact and display it in a buffer

;; In that buffer, you can:

;; - press m to generate an e-mail to that contact
;; - press C-l l to store an org-mode link to that contact

;; org-mode links have the format khard:<uid>#<name>

;;; Code

(require 'yaml-mode)
(require 'yaml)

(defvar-local khard-ag-contact nil
  "Store the contact associated with current buffer.
If nil, the buffer represents a new contact.")

;; FIXME: elide all the entries that are null

(defun khard-ag-show ()
  "Show CONTACT in a new buffer."
  (interactive)
  (let* ((addressbook (khard-ag-choose-addressbook))
	 (contact (khard-ag-choose-contact addressbook)))
    (khard-ag--show contact)))

(defun khard-ag--show (contact)
  (let ((buffer (generate-new-buffer (format "*khard-ag<%s>*" (cdr contact)))))
    (with-current-buffer buffer
      (call-process "khard" nil t nil "show" "--format" "yaml" (format "uid:%s" (car contact)))
      (goto-char (point-min))
      (khard-ag-show-mode)
      (read-only-mode)
      (setq-local khard-ag-contact contact))
    (switch-to-buffer buffer)))

(defun khard-ag--addressbooks ()
  "Let the user select an addressbook."
  (string-lines (with-output-to-string
		  (call-process "khard" nil standard-output nil "addressbooks"))))

(defun khard-ag-choose-addressbook ()
  "Let the user choose an addressbook."
  (let ((choice
	 (completing-read "Select an addresssbook: "
			  (cons "<all>" (khard-ag--addressbooks))
			  nil
			  t)))
    (if (equal choice "<all>")
	nil
      choice)))

(defun khard-ag-choose-contact (addressbook)
  "Let the user select a contact from a list of all contacts.
Return the contact."
  (let* ((contacts (khard-ag--list-contacts addressbook))
         (contact-name (completing-read "Select a contact: "
                                        (map-keys contacts)
                                        nil
                                        t)))
    (map-elt contacts contact-name)))

(defun khard-ag--list-contacts (addressbook)
  "Return a map whose keys are names and values are contacts."
  (save-match-data
    (with-temp-buffer
      (apply #'call-process "khard" nil t nil "ls" "--parsable"
	     (if addressbook
		 (list "--addressbook" addressbook)
	       '()))
      (goto-char (point-min))
      (let ((contacts (make-hash-table :test 'equal)))
        (cl-loop
         while (re-search-forward "^\\([-a-z0-9]*\\)\t\\(.*\\)\t[^\t]*$" nil t)
         do (setf (map-elt contacts (match-string 2)) (cons (match-string 1) (match-string 2)))
         finally return contacts)))))

(defvar khard-ag-show-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "m") #'khard-ag-prepare-email)
    (define-key map (kbd "C-c m") #'khard-ag-prepare-email)
    (define-key map (kbd "q") #'ag-khard-show-quit)
    map)
  "Keymap for `khard-ag-show-mode'.")

(defun ag-khard-show-quit ()
  (kill-buffer (current-buffer)))

(defun ag-khard-normalize-emails (emails)
  (apply #'append
	 (mapcar (lambda (entry)
		   (cond
		    ((eq :null entry) '())
		    ((stringp entry) (list entry))
		    ((listp entry) entry)
		    ((vectorp entry) (append entry nil))))
		 emails)))

(defun khard-ag-emails ()
  (let ((s (buffer-string)))
    (set-text-properties 0 (length s) nil s)
    (let* ((props (yaml-parse-string s :object-type 'alist))
	   (emails (mapcar #'cdr (cdr (assq 'Email props)))))
      (ag-khard-normalize-emails emails))))

(defun khard-ag-prepare-email ()
  (interactive)
  (let* ((emails (khard-ag-emails))
	 (email
	  (cond
	   ((null emails) (error "no email in this vCard"))
	   ((null (cdr emails)) (car emails))
	   (t (completing-read "Select email: " emails)))))
    (when (stringp email)
      (compose-mail email))))

(define-derived-mode khard-ag-show-mode yaml-mode "Khard-ag"
  "Show a contact through a YAML representation.")

(org-link-set-parameters "khard"
			 :follow #'khard-ag-follow-link
			 :store #'khard-ag-store-link)


(defun khard-ag-follow-link (link _)
  (let ((parts (string-split (string-remove-prefix "khard:" link) "#" t)))
    (unless (length= parts 2)
      (error "invalid khard:link: %s" link))
    (khard-ag--show (cons (car parts)
			  (or (cadr parts) "org contact")))))

(defun khard-ag-store-link ()
  (when (eq major-mode 'khard-ag-show-mode)
    (let ((link (concat "khard:"
			(car khard-ag-contact)
			"#" (cdr khard-ag-contact))))
      (org-link-store-props :type "khard" 
			    :link link
			    :description (cdr khard-ag-contact))
      link)))

(provide 'khard-ag)
;;; khard-ag.el ends here
