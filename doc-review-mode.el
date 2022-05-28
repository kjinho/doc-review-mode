;;; doc-review-mode.el --- reviewing documents w/ pdf-tools -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Jin-Ho King
;;
;; Author: Jin-Ho King <j@kingesq.us>
;; Maintainer: Jin-Ho King <j@kingesq.us>
;; URL: https://github.com/kjinho/doc-review-mode
;; 

(require 'pdf-tools)

(defun replace-underscore-with-latex (string)
  "Replaces underscores ``_\" with \\under{}"
  (replace-regexp-in-string "_" "\\under{}" string nil t))

(defun insert-citation-from-PDF-in-other-window ()
  "Inserts the citation from the PDF in the other window."
  (interactive)
  (let ((citation-text
         (with-current-buffer (window-buffer (next-window))
           (pcase major-mode
             ('pdf-view-mode 
              (let* ((docname (file-name-base (pdf-view-buffer-file-name)))
                     (pagenum (pdf-view-current-page))
                     (docsearch (string-match
                                 "\\(.*\\), \\([A-Z][a-z][a-z][a-z.] [0-9]?[0-9], [0-9][0-9][0-9][0-9]\\)"
                                 docname))
                     (docsearchdata (match-data))
                     ;; (docpart1 (match-string 1 docname))
                     ;; (docpart2 (match-string 2 docname))
                     (volsearch (string-match
                                 "\\(.*vol\\. [IVX0-9]+\\)"
                                 docname))
                     (volsearchdata (match-data)))
                ;; (volpart1 (match-string 1 docname)))
                (cond ((and docsearch (null volsearch))
                       (set-match-data docsearchdata)
                       (format "%s %d, %s"
                               (match-string 1 docname)
                               pagenum
                               (match-string 2 docname)))
                      ((not (null volsearch))
                       (set-match-data volsearchdata)
                       (format "%s, %d"
                               (match-string 1 docname)
                               pagenum))
                      (t
                       (format "%s at %d" docname pagenum)))))
             (other (progn
                      (message (format "Don't know how to insert from `%s'!" other))
                      ""))))))
    (insert
     (pcase major-mode
       ('org-mode
        (replace-underscore-with-latex citation-text))
       (_ citation-text)))))

(defun doc-review-advance-other-pdf ()
  (interactive)
  (other-window 1)
  (pcase major-mode
    ('pdf-view-mode  
     (pdf-view-next-page))
    (other
     (message (format "Do not know how to handle `%s'!" other))))
  (other-window -1))
  ;; (with-current-buffer (window-buffer (next-window))
  ;;   (pdf-view-next-page)))

(defun doc-review-rewind-other-pdf ()
  (interactive)
  (other-window 1)
  (pcase major-mode
    ('pdf-view-mode  
     (pdf-view-previous-page))
    (other
     (message (format "Do not know how to handle `%s'!" other))))
  (other-window -1))
  ;; (with-current-buffer (window-buffer (next-window))
  ;;   (pdf-view-previous-page)))

(defvar doc-review-mode-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap of command `doc-review-mode'.")

;;;###autoload
(define-minor-mode doc-review-mode
  "Toggle Doc Review mode.
Interactively with no argument, this command toggles the mode.
A positive prefix argument enables the mode, any other prefix
argument disables it.  From Lisp, argument omitted or nil enables
the mode, `toggle' toggles the state.

When Doc Review mode is enabled, provides key-bindings to
control a PDF in the next window."
  :initial-value nil
  :lighter " DocReview"
  :keymap doc-review-mode-mode-map)
  ;; `((,(kbd "C-c n") . doc-review-advance-other-pdf)
  ;;   (,(kbd "C-c p") . doc-review-rewind-other-pdf)
  ;;   (,(kbd "C-c w") . insert-citation-from-PDF-in-other-window)))

(provide 'doc-review-mode)
