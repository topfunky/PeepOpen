;; peepopen.el --- Graphical file chooser for Emacs on Mac OS X.

;; Copyright (C) 2010 Topfunky Corporation <http://peepcode.com>

;; Licensed under the same terms as Emacs.

;; Version: 0.1.0
;; Keywords: textmate osx mac
;; Created: 8 April 2010
;; Author: Geoffrey Grosenbach <boss@topfunky.com>

;; This file is NOT part of GNU Emacs.

;; Licensed under the same terms as Emacs.

;;; Commentary:

;; A sensible fuzzy file chooser with a beautiful Mac OS X GUI.
;;
;; This minimal enhancement to textmate-mode calls the external
;; PeepOpen.app when you hit Command-T (or equivalent).

;;    ⌘T - Go to File

;;; Installation:

;; This plugin assumes that you've already loaded Chris Wanstrath's
;; textmate.el in your emacs configuration. Load this file afterward.
;;
;; Copy this file to ~/.emacs.d/vendor/peepopen.el (or use the menu
;; item in the PeepOpen application).

;; $ cd ~/.emacs.d/vendor
;; $ git clone git://github.com/defunkt/textmate.el.git

;; (add-to-list 'load-path "~/.emacs.d/vendor/textmate.el")
;; (require 'textmate)
;; (textmate-mode)
;; (add-to-list 'load-path "~/.emacs.d/vendor/")
;; (require 'peepopen)

(defun peepopen-goto-file-gui ()
  "Uses external GUI app to quickly jump to a file in the project."
  (interactive)
  (let ((root (textmate-project-root)))
    (when (null root)
      (error
       (concat
        "Can't find a suitable project root ("
        (string-join " " *textmate-project-roots* )
        ")")))
    (shell-command-to-string
     (format "open -a PeepOpen '%s'"
             (expand-file-name root)))))

(defun peepopen-bind-keys ()
  (if (boundp 'aquamacs-version)
      (peepopen-bind-aquamacs-keys)
    (peepopen-bind-carbon-keys)))

(defun peepopen-bind-aquamacs-keys ()
  ;; Need `osx-key-mode-map' to override
  (define-key osx-key-mode-map (kbd "A-t") 'peepopen-goto-file-gui))

(defun peepopen-bind-carbon-keys ()
  (define-key *textmate-mode-map* [(meta t)] 'peepopen-goto-file-gui))

(defun string-join (separator strings)
  "Join all STRINGS using SEPARATOR."
  (mapconcat 'identity strings separator))

(peepopen-bind-keys)

(provide 'peepopen)
