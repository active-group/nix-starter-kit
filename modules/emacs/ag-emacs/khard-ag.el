;;; khard-ag.el --- Display and link to khard contacts              -*- lexical-binding: t; -*-

;;; Commentary:

;; M-x khard-ag-show
;; to select a khard contact and display it in a buffer

;; In that buffer, you can:

;; - press m to generate an e-mail to that contact
;; - press d to dial the phone number of that contact
;; - press e to edit the entry of that contact
;; - press C-l l to store an org-mode link to that contact
;; - press q to quit

;; org-mode links have the format khard:<uid>#<name>

;;; Code

(require 'yaml-mode)
(require 'yaml)
(require 'khardel)
(require 'ol) ; Org links library

(defvar-local khard-ag-contact nil
  "Store the contact associated with current buffer.
If nil, the buffer represents a new contact.")

(defun khard-ag-show ()
  "Show CONTACT in a new buffer."
  (interactive)
  (let* ((addressbook (khard-ag-choose-addressbook))
	 (contact (khard-ag-choose-contact addressbook)))
    (khard-ag--show contact)))

(defun khard-ag--show (contact)
  (let* ((yaml
	  (with-temp-buffer
	    (call-process "khard" nil t t "show" "--format" "yaml" (format "uid:%s" (car contact)))
	    (khard-ag--yaml)))
	 (buffer (generate-new-buffer (format "*khard-ag<%s>*" (cdr contact)))))
    (with-current-buffer buffer
      (insert (yaml-encode (khard-ag--sanitize-yaml yaml)))
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

(defun khard-ag--sanitize-yaml (props)
  (seq-filter #'identity
	      (seq-map (lambda (entry)
			 (cond
			  ((eq (cdr entry) :null)
			   nil)
			  ((listp (cdr entry))
			   (let ((sanitized
				  (khard-ag--sanitize-yaml (cdr entry))))
			     (if (null sanitized)
				 '()
			       (cons (car entry)
				     sanitized))))
			  (t entry)))
		       props)))
   
(defvar khard-ag-show-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "m") #'khard-ag-prepare-email)
    (define-key map (kbd "C-c m") #'khard-ag-prepare-email)
    (define-key map (kbd "q") #'khard-ag-show-quit)
    (define-key map (kbd "e") #'khard-ag-show-edit)
    (define-key map (kbd "d") #'khard-ag-show-dial)
    map)
  "Keymap for `khard-ag-show-mode'.")

(defun khard-ag-show-quit ()
  (interactive)
  (kill-buffer (current-buffer)))

(defun khard-ag-show-edit ()
  (interactive)
  (khardel-edit-contact khard-ag-contact))

(defun khard-ag--normalize-entries (emails)
  (apply #'append
	 (mapcar (lambda (entry)
		   (cond
		    ((eq :null entry) '())
		    ((stringp entry) (list entry))
		    ((listp entry) entry)
		    ((vectorp entry) (append entry nil))))
		 emails)))

(defun khard-ag--yaml ()
  (let ((s (buffer-string)))
    (set-text-properties 0 (length s) nil s)
    (yaml-parse-string s :object-type 'alist)))

(defun khard-ag-emails ()
  (let* ((props (khard-ag--yaml))
	 (emails (mapcar #'cdr (cdr (assq 'Email props)))))
    (khard-ag--normalize-entries emails)))

(defun khard-ag-phones ()
  (let* ((props (khard-ag--yaml))
	 (phones (mapcar #'cdr (cdr (assq 'Phone props)))))
    (khard-ag--normalize-entries phones)))

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

(defun khard-ag--dial (phone-string)
  (let ((sanitized (replace-regexp-in-string "[-() ]" "" "(0162) 2153292"))) ; funky things happen with parens in phone numbers
    (browse-url (concat "tel:" phone-string))))

(defun khard-ag-show-dial ()
  (interactive)
  (let* ((phones (khard-ag-phones))
	 (phone
	  (cond
	   ((null phones) (error "no phone in this vCard"))
	   ((null (cdr phones)) (car phones))
	   (t (completing-read "Select phone: " phones)))))
    (when (stringp phone)
      (khard-ag--dial phone))))

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
