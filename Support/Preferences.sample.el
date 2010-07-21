;; Sample configuration for using PeepOpen with Aquamacs.
;;
;; Put this in ~/Library/Application Support/Aquamacs Emacs/Preferences.el

(add-to-list 'load-path "~/Library/Application Support/Aquamacs Emacs/vendor")
(require 'textmate)
(require 'peepopen)
(textmate-mode)

;; For Emacs on Mac OS X http://emacsformacosx.com/ and Aquamacs.
;; Opens files in the existing frame instead of making new ones.
(setq ns-pop-up-frames nil)

