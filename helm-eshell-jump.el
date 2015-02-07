;;; helm-eshell-jump -*- lexical-binding: t; coding: utf-8; -*-

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'seq)
(require 'helm)

(defvar helm-eshell-jump-last-dir-candidates nil)

(cl-defun helm-eshell-jump-last-dir-init ()
  (setq helm-eshell-jump-last-dir-candidates
        (helm-eshell-jump-last-dir-create-candidates)))

(cl-defun helm-eshell-jump-last-dir-create-candidates ()
  (cl-letf ((orig (cddr eshell-last-dir-ring)))
    (seq-map
     #'identity
     orig)))

(cl-defun helm-eshell-jump-action-cd (candidate)
  (eshell-kill-input)
  (insert (format "cd %s" candidate))
  (eshell-send-input))

(defclass helm-eshell-jump-last-dir-source (helm-source-sync)
  ((init :initform #'helm-eshell-jump-last-dir-init)
   (candidates :initform 'helm-eshell-jump-last-dir-candidates)
   (action :initform
           (helm-make-actions
            "Change to directory" #'helm-eshell-jump-action-cd))))

(defvar helm-source-eshell-jump-last-dir
  (helm-make-source "Last directories"
      'helm-eshell-jump-last-dir-source))


(defcustom helm-eshell-jump-directories
  `(("Home" . "~/")
    (".emacs.d" . ,user-emacs-directory))
  "Directories to jump")

(defvar helm-eshell-jump-candidates nil)

(cl-defun helm-eshell-jump-init ()
  (setq helm-eshell-jump-candidates
        (helm-eshell-jump-create-candidates)))

(cl-defun helm-eshell-jump-create-candidates ()
  (cl-letf ((orig helm-eshell-jump-directories))
    (seq-map
     #'identity
     orig)))

(defclass helm-eshell-jump-source (helm-source-sync)
  ((init :initform #'helm-eshell-jump-init)
   (candidates :initform 'helm-eshell-jump-candidates)
   (action :initform
           (helm-make-actions
            "Change to directory" #'helm-eshell-jump-action-cd))))

(defvar helm-source-eshell-jump
  (helm-make-source "Directories"
      'helm-eshell-jump-source))

;;;###autoload
(cl-defun helm-eshell-jump-add-directory (dir)
  (setq helm-eshell-jump-directories
        (append helm-eshell-jump-directories
                (list dir))))

;;;###autoload
(cl-defun helm-eshell-jump ()
  (interactive)
  (helm :sources '(helm-source-eshell-jump-last-dir
                   helm-source-eshell-jump)
        :buffer "*helm eshell jump*"))

(provide 'helm-eshell-jump)

;;; helm-eshell-jump.el ends here