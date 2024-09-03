;;; ox-mediawiki-gentoo.el --- mediawiki exporter extension for gentoo specific mediawiki syntax  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Penguin

;; Author: Penguin <penguin@epenguin.net>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(eval-when-compile (require 'cl-lib))
(require 's)
(require 'ox-mediawiki)

;;; User-Configurable Variables

(defgroup org-export-mwg nil
  "Options specific to Gentoo's Mediawiki export backend."
  :tag "Org Mediawiki Gentoo"
  :group 'org-export
  :version "29.1"
  :package-version '(Org . "9.0"))

(org-export-define-derived-backend 'gmw 'mw
  :filters-alist '((:filter-parse-tree . org-mw-separate-elements))
  :menu-entry
  '(?m "Export to Gentoo flavored Mediawiki"
    ((?G "To temporary buffer"
         (lambda (a s v b) (org-gmw-export-as-mediawiki a s v)))
     (?g "To file" (lambda (a s v b) (org-gmw-export-to-mediawiki a s v)))
     ))
  :translate-alist '((src-block . org-gmw-example-block)))


(defun org-gmw-example-block (example-block contents info)
  "Transcode EXAMPLE-BLOCK element into Mediawiki format.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (concat
   (replace-regexp-in-string
    "^" "{{Cmd|"
    (replace-regexp-in-string "\n" ""
                               (org-remove-indentation
                                (org-element-property :value example-block)))) "}}\n"))



;;; Interactive function

;;;###autoload
(defun org-gmw-export-as-mediawiki (&optional async subtreep visible-only)
  "Export current buffer to a Mediawiki buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Export is done in a buffer named \"*Org MW Export*\", which will
be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (if async
      (org-export-async-start
          (lambda (output)
            (with-current-buffer (get-buffer-create "*Org MW Export*")
              (erase-buffer)
              (insert output)
              (goto-char (point-min))
              (text-mode)
              (org-export-add-to-stack (current-buffer) 'gmw)))
        `(org-export-as 'gmw ,subtreep ,visible-only))
    (let ((outbuf (org-export-to-buffer
                      'gmw "*Org GMW Export*" subtreep visible-only)))
      (with-current-buffer outbuf (text-mode))
      (when org-export-show-temporary-export-buffer
        (switch-to-buffer-other-window outbuf)))))



(defun org-gmw-export-to-mediawiki (&optional async subtreep visible-only)
  "Export current buffer to a Mediawiki file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name
                  org-mw-filename-extension subtreep)))
    (if async
 (org-export-async-start
            (lambda (f) (org-export-add-to-stack f 'gmw))
          `(expand-file-name
            (org-export-to-file 'gmw ,outfile ,subtreep ,visible-only)))
      (org-export-to-file 'gmw outfile subtreep visible-only))))
(provide 'ox-mediawiki-gentoo)
;;; ox-mediawiki-gentoo.el ends here
