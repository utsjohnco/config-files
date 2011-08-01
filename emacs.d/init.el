(add-to-list 'load-path "~/.emacs.d/site-lisp")

(require 'tabbar)
(require 'color-theme)
(require 'zenburn)
(require 'flymake)
(require 'auto-complete-config)
(require 'xcscope)
(require 'cl)
(require 'lua-mode)
(require 'markdown-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keybindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key "\M-g"      'goto-line)
(global-set-key [C-prior]   'tabbar-backward)
(global-set-key [C-next]    'tabbar-forward)
(global-set-key [C-tab]     'toggle-tabs-mode)
(global-set-key [backtab]   'toggle-tab-width)
(global-set-key
    (kbd "C-c C-c")         'comment-region)
(global-set-key "\M-\r"     'toggle-fullscreen)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq kill-whole-line        t)   ; C-k removes newline as well
(setq next-line-add-newlines nil) ; don't add newlines when past end of buffer
(setq require-final-newline  t)   ; require \n at end of buffer
(delete-selection-mode       t)   ; delete selection when delete is pressed
(setq transient-mark-mode    t)   ; handle selections sanely
(setq fill-column            80)  ; when filling text, fill 80 characters/line
(setq indent-tabs-mode       nil) ; use spaces for indentation
(fset 'yes-or-no-p     'y-or-n-p) ; ask y/n instead of yes/no
(setq scroll-conservatively  1)   ; better scrolling behavrio
(setq inhibit-startup-message t)  ; don't show emacs screen at startup
(which-function-mode          t)  ; show function name in modeline
(add-to-list                      ; turn on auto complete mode
     'ac-dictionary-directories
     "/usr/share/emacs23/site-lisp/ac-dict")
(ac-config-default)
(put 'downcase-region 'disabled nil) ; don't disble these commands,
(put 'upcase-region   'disabled nil) ; I think they're useful

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq auto-mode-alist (cons '("\\.lua$" . lua-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.md$" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cnote-theme$" . js-mode) auto-mode-alist))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-face-attribute 'default nil :height 100 :family "Bitstream Vera Sans Mono")
(global-font-lock-mode   t)   ; turn on decorations in all modes
(tabbar-mode             1)   ; show tabbar and menu bar
(menu-bar-mode           1) 
(tool-bar-mode           0)   ; hide toolbar and scroll bar
(scroll-bar-mode         0)
(setq visible-bell       t)   ; use flashing buffer instead of audible beep
(setq line-number-mode   t)   ; show line and column in mode line
(setq column-number-mode t)
(display-time-mode       nil) ; hide time in mode line
(setq tab-width          4)   ; default tab width is 4 spaces 
(setq c-basic-offset     4)   ; yes, still 4 spaces

(setq frame-title-format      ; show 'user@host: buffername*' as frame title
      (list (user-login-name)
            "@" (system-name)
            ": %b %+" ))
(setq truncate-partial-width-windows nil) ; no line truncating in split windows
(color-theme-initialize)
(color-theme-zenburn)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; save backup files in a non-annoying place
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq backup-directory-alist
      `((".*" . ,"/home/john/.cache/emacs/")))
(setq auto-save-file-name-transforms
      `((".*" ,"/home/john/.cache/emacs/" t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; color theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun toggle-tabs-mode ()
  "Toggle variable indent-tabs-mode between t and nil."
  (interactive)
  (set-variable 'indent-tabs-mode (not indent-tabs-mode))
  (message "tabs-mode set to %s" indent-tabs-mode))

(defun toggle-tab-width ()
  "Toggle variable tab-width between 8 and 4."
  (interactive)
  (set-variable 'tab-width (if (= tab-width 8) 4 8))
  (message "tab-width set to %d" tab-width))

(defun toggle-fullscreen ()
  "Switch between fullscreen and windowed mode"
  (interactive)
  (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen)
										   nil
										 'fullboth)))

(defun hexcolour-luminance (color)
  "Calculate the luminance of a color string (e.g. \"#ffaa00\", \"blue\").
  This is 0.3 red + 0.59 green + 0.11 blue and always between 0 and 255."
  (let* ((values (x-color-values color))
         (r (car values))
         (g (cadr values))
         (b (caddr values)))
    (floor (+ (* .3 r) (* .59 g) (* .11 b)) 256)))

(defun hexcolour-add-to-font-lock ()
  "Colorize HTML RGB colors (e.g. '#0000F0', 'blue') in font-lock-mode."
  (interactive)
  (font-lock-add-keywords nil
	`((,(concat "#[0-9a-fA-F]\\{6\\}\\|"
                (regexp-opt (x-defined-colors) 'words))
	   (0 (let ((colour (match-string-no-properties 0)))
            (put-text-property
             (match-beginning 0) (match-end 0)
             'face `((:foreground ,(if (> 128.0 (hexcolour-luminance colour))
                                       "white" "black"))
                     (:background ,colour)))))))))

(defun c-return ()
  "indent automatically on return"
  (interactive)
  (c-indent-line-or-region)
  (newline-and-indent))

(defun cish-lang-hook ()
  " setup C-ish mode (C/C++)"
  (c-set-style   "k&r")
  (local-set-key [13] 'c-return)
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (setq c-basic-offset 4)
  (c-set-offset  'substatement-open  0) ; no indent for opening {
  (show-paren-mode 1) ; highlight matching parens
  (c-toggle-auto-hungry-state 1) ; insert newlines when appropriate
										; and do greedy whitespace delete
  (flymake-mode t) ; turn on flymake
)

(defun on-text-mode ()
  "turn on flyspell"
  (flyspell-mode t)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hooks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'css-mode-hook  'hexcolour-add-to-font-lock)
(add-hook 'nxml-mode-hook 'hexcolour-add-to-font-lock)
(add-hook 'emacs-lisp-mode-hook 'hexcolour-add-to-font-lock)

(add-hook 'c-mode-hook    'cish-lang-hook)
(add-hook 'c++-mode-hook  'cish-lang-hook)
(add-hook 'text-mode-hook 'on-text-mode)

(add-hook 'window-setup-hook 'delete-other-windows) ; only one window on startup


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flymake crap.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (load "flymake" t) 
  ; don't show a goddamn dialog box every single time flymake cocks up
  (defun flymake-display-warning (warning) 
	"Display a warning to the user, using lwarn"
	(message warning))


  ; turn on flymake mode for python using pyflakes
  (defun flymake-pyflakes-init () 
    (let* ((temp-file (flymake-init-create-temp-buffer-copy 
		       'flymake-create-temp-inplace)) 
	   (local-file (file-relative-name 
			temp-file 
			(file-name-directory buffer-file-name)))) 
      (list "pychecker" (list local-file)))))
  
(add-to-list 'flymake-allowed-file-name-masks 
	     '("\\.py\\'" flymake-pyflakes-init)) 

(add-hook 'find-file-hook 'flymake-find-file-hook)

; use chtex for tex instead of texify
(defun flymake-get-tex-args (file-name)
  (list "chktex" (list "-q" "-v0" file-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tabbar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; list all buffers together except emacs buffers
(defun tabbar-buffer-groups ()
  "Return the list of group names the current buffer belongs to.
 This function is a custom function for tabbar-mode's tabbar-buffer-groups.
 This function group all buffers into 3 groups:
 Those Dired, those user buffer, and those emacs buffer.
 Emacs buffer are those starting with “*”."
  (list
   (cond
    ((string-equal "*" (substring (buffer-name) 0 1))
     "Emacs Buffer"
     )
    ((eq major-mode 'dired-mode)
     "Dired"
     )
    (t
     "User Buffer"
     )
    ))) ;; from Xah Lee

(setq tabbar-buffer-groups-function 'tabbar-buffer-groups)

;; make tabbar colors fit in with zenburn theme
(setq tabbar-background-color "#2e3330")
(set-face-attribute  'tabbar-default nil
                     :foreground zenburn-fg
                     :background "#2e3330"
                     :box nil)
(set-face-attribute  'tabbar-unselected nil
                     :background "#2e3330"
                     :foreground zenburn-fg
                     :box nil)
(set-face-attribute  'tabbar-selected nil
                     :background zenburn-bg
                     :foreground zenburn-red+1
                     :box nil)
(set-face-attribute  'tabbar-button nil
                     :box nil)
(set-face-attribute  'tabbar-separator nil
                     :height 1.7
                     :box nil)
(set-face-bold-p    'tabbar-selected t)