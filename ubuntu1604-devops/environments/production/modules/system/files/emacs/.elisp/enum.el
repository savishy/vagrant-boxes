;;; enum.el --- Automatische Aufzählungen
;; Copyright (C) 2002
;; Author: Karl Pflästerer <sigurd@12move.de>
;; Version 1.0
;;; Commentary:
;; This code gives you the possibility to enter enumerations
;; automagically.
;; Add to the approbiate hook eg. `text-mode-hook'
;;              (require 'enum)
;;              (enum-initialize)
;; The keybindings in that file are only active in text-mode. Change
;; it to your needs.
;; The variable enum-styles-alist is the core of all (evil).
;; It is an alist of which the key is a string.  That string is also
;; used in the minibuffer if you want to change the style.  The value
;; of the alist is a list with three or four elements.  The first
;; element is the name of a function or nil.  If there is no fourth
;; element that function is called with one parameter the
;; level-counter.  With a fourth element that function is called with
;; level-counter and the fourth element which should be a variable or
;; a string of which the elements are used as markers. The counter is
;; used as index and cycles through the string.  The second and third
;; element are the left and the right delimeter of the mark. They must
;; be strings.
;; ("Small letter with parenthesis"
;;           ;; (a) (b)
;;           enum-num-to-char "(" ") " enum-alph-string)
;; is a typical entry.
;;     o enum-num-to-char is a function that takes two parameters
;;      - a number (here the markercounter of the level)
;;      - a string (here `enum-alph-string') of which each character
;;        is used as a enumeration marker.
;;     o `"("' and `") "' are the left and the right delimiter.
;; The default style for the first level is the first entry of this
;; alist; the last entry is the default style for the second level.
;; If you use `filladapt-mode' (really cool) this file adds regexps to
;; `filladapt-token-table' so all expressions are groked from
;; filladapt.
;; You can also change existing enumerations in one level to another
;; enumeration style.  This can be done with changing *all* markers of
;; that level `enum-choose-reformat-style' or without
;; `enum-choose-style'.
;; You can also use this feature, if you deleted some markers and want
;; to have renumber them. Just change to the actual style and all will
;; be fine.
;; At the moment all markers of one level are enumerated in a row also
;; the counter may have been resetted by hand. Should be fixed.
;; Each level markers have their own colour. They can be set with the
;; variables `enum-level-one-colour' or `enum-level-two-color'. The
;; value is the name of a face e.g. `font-lock-string-face'.
;;; Code:
;; defvars are needed so the byte-compiler does'nt barf
(eval-when-compile
 (require 'filladapt))
(defvar enum-level-one-counter nil
  "Level 1 Counter.")
(defvar enum-level-two-counter nil
  "Level 2 Counter. ")
(defvar enum-level-counter nil
  "Variable with values 1 or 2 indicating actual level. ")
(defvar enum-level-one-style nil
  "Variable holding key for actual level 1 style. ")
(defvar enum-level-two-style nil
  "Variable holding key for actual level 2 style. ")
(defconst enum-colour-p t
  "Do we want coloured markers?")
(defconst enum-level-one-colour
    (if enum-colour-p
      'font-lock-string-face
      nil)
  "Colour used to indicate enumeratuions of level 1 (only the
markers.")
(defconst enum-level-two-colour
    (if enum-colour-p
      'font-lock-function-name-face
      nil)
  "Colour used to indicate enumeratuions of level 2 (only the
markers.")
(defconst enum-alph-string "abcdefghijklmnopqrstuvwxyz"
  "String of all small roman letters. ")
(defconst enum-big-alph-string "ABCDEFGHIJKLMONOPQRSTUVWXYZ"
  "String of all big roman letters. ")
(defconst enum-bullet1-string "·"
  "A bullet '·'. ")
(defconst enum-bullet2-string "o"
  "A bullet 'o'. ")
(defconst enum-hyphen-string "-"
  "A hyphen '-'. ")
(defconst enum-star-string "*"
  "A star '*'. ")
(defconst enum-triangle-string ">"
  "A '>'. ")
(defconst enum-level-one-prefix ""
  "A prefix to insert before every marker of level one. ")
(defconst enum-level-two-prefix "   "
  "A prefix (most some space chars) to insert before every marker of
level two. ")
(defconst enum-styles-alist nil
  "Alist. Its keys are unique strings for each style.
The values are 3 or 4 entries. Look in the commentary. ")
(if (boundp 'filladapt-token-table) nil
  (defvar filladapt-token-table nil))
;;; *****************************************************************
;;; User Functions
;;; *****************************************************************
(defun enum-initialize ()
  (interactive)
  (make-variable-buffer-local 'enum-colour-p)
  (make-variable-buffer-local 'enum-level-one-counter)
  (make-variable-buffer-local 'enum-level-two-counter)
  (make-variable-buffer-local 'enum-level-counter)
  (make-variable-buffer-local 'enum-level-one-style)
  (make-variable-buffer-local 'enum-level-two-style)
  (make-variable-buffer-local 'enum-level-one-prefix)
  (make-variable-buffer-local 'enum-level-two-prefix)
  (make-variable-buffer-local 'enum-alph-string)
  (make-variable-buffer-local 'enum-big-alph-string)
  (make-variable-buffer-local 'enum-bullet1-string)
  (make-variable-buffer-local 'enum-bullet2-string)
  (make-variable-buffer-local 'enum-hyphen-string)
  (make-variable-buffer-local 'enum-triangle-string)
  (make-variable-buffer-local 'enum-level-one-colour)
  (make-variable-buffer-local 'enum-level-two-colour)
  (make-variable-buffer-local 'enum-star-string)
  (make-variable-buffer-local 'enum-styles-alist)
  (make-variable-buffer-local 'filladapt-token-table)
  (setq enum-styles-alist
          '(("Small letter with parenthesis"
             ;; (a) (b)
             enum-num-to-char "(" ") " enum-alph-string)
            ("Small letter without parenthesis"
             ;; *a* *b*
             enum-num-to-char "*" "* " enum-alph-string)
            ("Big letter with parenthesis"
             ;; (A) (B)
             enum-num-to-char "(" ") " enum-big-alph-string)
            ("Big letter without parenthesis"
             ;; *A* *B*
             enum-num-to-char "*" "* " enum-big-alph-string)
            ("Arabian digit with parenthesis"
             ;; (1) (2)
             enum-width-2 "(" ") ")
            ("Arabian digit without parenthesis"
             ;; 1. 2.
             enum-width-2 "" ". ")
            ("Big roman digit with brackets"
             ;; [I] [II]
             enum-width-4-bigroman "[" "] ")
            ("Big roman digit with stars"
             ;; *I* *II*
             enum-width-4-bigroman "*" "* ")
            ("Small roman digit with parentheses"
             ;; (i) (ii)
             enum-width-4-smallroman "(" ") ")
            ("Small roman digit with stars"
             ;; *i* *ii*
             enum-width-4-smallroman "*" "* ")
            ("Enumeration with hyphen'-'"
             ;; - -
             enum-num-to-char " " " " enum-hyphen-string)
            ("Enumeration with small arrow'->'"
             ;; -> ->
             enum-num-to-char "-" " " enum-triangle-string)
            ("Enumeration with small bullet '·'"
             ;; · ·
             enum-num-to-char " " " " enum-bullet1-string)
            ("Enumeration with star '*'"
             ;; * *
             enum-num-to-char " " " " enum-star-string)
            ("Enumeration with big bullet 'o'"
             ;; o o
             enum-num-to-char " " " " enum-bullet2-string)))
  ;; values
  (setq enum-level-one-counter 1
        enum-level-two-counter 1
        enum-level-counter 1)
  ;; we start
  (setq filladapt-token-table
          (append filladapt-token-table
                  (mapcar (lambda (x)
                            (list
                             (concat
                              ;; left delimiter
                              (regexp-quote (nth 1 (cdr x)))
                              ;; the marker
                              (concat "[" (regexp-quote
                                           (or (eval (nth 3 (cdr x)))
                                               "a-z"))"]+")
                              ;; right delimiter
                              (regexp-quote (nth 2 (cdr x))))
                             'bullet))
                          enum-styles-alist)))
  (setq enum-level-one-style (caar enum-styles-alist))
  (setq enum-level-two-style (caar (reverse enum-styles-alist))))
(defun enum-insert-enum (&optional switch)
  "Inserts automagically an enumaration.  The enum style can be set
with `enum-choose-style'.  With an optional prefix the level is
changed. If you choose another enumeration style *all* markers of this
level are changed to that new style.
Keybindings:
`enum-insert-enum'           is bound to \\[enum-insert-enum]
`enum-choose-style'          is bound to \\[enum-choose-style]
`enum-choose-reformat-style' is bound to \\[enum-choose-reformat-style]
`enum-setup-indent-levels'   is bound to \\[enum-setup-indent-levels]
`enum-renumber-enums'        is bound to \\[enum-renumber-enums]
`enum-reset-counter-one'     is bound to \\[enum-reset-counter-one]
`enum-reset-counter-two'     is bound to \\[enum-reset-counter-two] ."
  (interactive "P")
  (if (not enum-level-one-counter)
    (enum-initialize))
  (if switch
    (enum-switch-level))
  (cond ((= enum-level-counter 1)
          (enum-insert enum-level-one-counter enum-styles-alist
                       enum-level-one-style "\n" enum-level-one-prefix)
          (enum-make-extent (point-at-bol) (- (point) 1) enum-level-counter)
          (++ enum-level-one-counter))
        (t
          (enum-insert enum-level-two-counter enum-styles-alist
                       enum-level-two-style "\n" enum-level-two-prefix)
          (enum-make-extent (point-at-bol) (- (point) 1) enum-level-counter)
          (++ enum-level-two-counter))))
(defun enum-choose-style (&optional switch)
  "Chooses the style. Optional Prefix allows to choose the style of the
inactive level. The counter for the markers is reset to 1."
  (interactive "P")
  (if (not enum-level-one-counter)
    (enum-initialize))
  ;; Keys in history
  (let ((enum-history-list
          (mapcar 'car enum-styles-alist))
        (levelcounter enum-level-counter)
        (enum-styles-alist-minib enum-styles-alist))
    (if switch
      (switch levelcounter))
    (if (= levelcounter 1)
      (progn
        (setq enum-level-one-style
                (enum-choose levelcounter enum-history-list
                             enum-styles-alist-minib))
        (enum-reset-counter-one))
      (progn
        (setq enum-level-two-style
                (enum-choose levelcounter (reverse enum-history-list)
                             enum-styles-alist-minib))
        (enum-reset-counter-two)))))
(defun enum-choose-reformat-style (&optional switch)
  "Chooses the style. Optional Prefix allows to choose the style of the
inactive level. Also all markers of the changed level get changed to
the new style.  The  counter for the markers == number of markers."
  (interactive "P")
  (if (not enum-level-one-counter)
    (enum-initialize))
  ;; Keys in history
  (let ((enum-history-list
          (mapcar 'car enum-styles-alist))
        (levelcounter enum-level-counter)
        (enum-styles-alist-minib enum-styles-alist))
    (if switch
      (switch levelcounter))
    (if (= levelcounter 1)
      (progn
        (setq enum-level-one-style
                (enum-choose levelcounter enum-history-list
                             enum-styles-alist-minib))
        (setq enum-level-one-counter
                (enum-renumber-markers levelcounter enum-level-one-style
                                       enum-styles-alist enum-level-one-prefix
                                       (point-min) (point-max))))
      (progn
        (setq enum-level-two-style
                (enum-choose levelcounter (reverse enum-history-list)
                             enum-styles-alist-minib))
        (setq enum-level-two-counter
                (enum-renumber-markers levelcounter enum-level-two-style
                                       enum-styles-alist enum-level-two-prefix
                                       (point-min) (point-max)))))))
(defun enum-setup-indent-levels (level1prefix level2prefix)
  "Allows you to choose the overall prefix for level one
`enum-level-one-prefix' and level two `enum-level-two-prefix'
interactivly.  You can choose spaces ore some fancy signs."
  (interactive
   (list (read-string "Level one prefix: " enum-level-one-prefix)
         (read-string "Level two prefix: " enum-level-two-prefix)))
  (setq enum-level-one-prefix level1prefix
        enum-level-two-prefix level2prefix))
(defun enum-renumber-enums (beg end)
  "Renumbers the markers in the actual level.  The levelcounter doesn't
get changed.  If you deleted some markers and you like the counter to be
set to the actual number of markers use `enum-choose-reformat-style'
instead.
You can mark a region than only the markers in that region get
renumbered."
  (interactive
   (if (region-active-p)
     (list (region-beginning) (region-end))
     (list (point-min) (point-max))))
  (enum-renumber-markers enum-level-counter
                         (if (= enum-level-counter 1)
                           enum-level-one-style
                           enum-level-two-style)
                         enum-styles-alist
                         (if (= enum-level-counter 1)
                           enum-level-one-prefix
                           enum-level-two-prefix) beg end))
(defun enum-reset-counter-one (&optional step nomessage)
  "Resets the counter for level one.  With an optional prefix the
counter is decremented the value of the prefix. The second optional
boolean argument specifies if used programmatically if a message
should not be written in the minibuffer."
  (interactive "P")
  (when (boundp 'enum-level-one-counter)
    (if (numberp step)
      (setq enum-level-one-counter (abs (- enum-level-one-counter step 1)))
      (setq enum-level-one-counter 1))
    (if nomessage
      nil
      (message "Level 1 counter now %d. " enum-level-one-counter))))
(defun enum-reset-counter-two (&optional step nomessage)
  "Resets the counter for level two.  With an optional prefix the
counter is decremented the value of the prefix. The second optional
boolean argument specifies if used programmatically if a message
should not be written in the minibuffer."
  (interactive "P")
  (when (boundp 'enum-level-two-counter)
    (if (numberp step)
      (setq enum-level-two-counter (abs (- enum-level-two-counter step 1)))
      (setq enum-level-two-counter 1))
    (if nomessage
      nil
      (message "Level 2 counter now %d. " enum-level-two-counter))))
;;; *****************************************************************
;;; Private Functions
;;; *****************************************************************
(defun enum-insert (counter argl key newline prefix)
  "Inserts our marker. counter is a number argl is an alist like
`enum-styles-alist' key is a valid key from that list. "
  (let ((str (eval (nth 4 (assoc key argl))))
        (func (cadr (assoc key argl)))
        (ldelim (caddr (assoc key argl)))
        (rdelim (cadddr (assoc key argl))))
    (cond (str                          ;a string
            (insert newline
                    prefix
                    ldelim
                    (funcall func counter str)
                    rdelim))
          (func                 ;we have a function
            (insert newline
                    prefix
                    ldelim
                    (funcall func counter)
                    rdelim))
          (t                            ;we want a plain digit
            (insert newline
                    prefix
                    ldelim
                    (int-to-string counter)
                    rdelim)))))
(defun enum-choose (lvl histl matchl)
  "Does the real work of choosing. lvl is a number indicating the enum
level. histl is a list which is used as history list; matchl is an
alist with the contents of histl as keys. "
  (or (car (assoc
            (completing-read
             (format
              "Level %s (use up/down to scroll)-> " lvl)
             matchl nil nil
             (if (= lvl 1) enum-level-one-style enum-level-two-style)
             '(histl . 0)) matchl))
      (progn
        (message
         (format "No valid key => %s"
                 (caar (reverse matchl))))
        (caar (reverse matchl)))))
(defun enum-switch-level ()
  "Switches the levels. "
  (switch enum-level-counter)
  (cond ((= enum-level-counter 1)
          (enum-reset-counter-two)
          (message "Now in Level 1. "))
        (t
          (message "Now in Level 2. "))))
;; Extents *********************************************************
(defun enum-make-extent (beg end level)
  "Creates extent and property list for that extent."
  (let ((ext (make-extent beg end)))
    (if (= level 1)
      (set-extent-properties ext (list level t 'face enum-level-one-colour
                                       'start-open t 'end-closed t))
      (set-extent-properties ext (list level t 'face enum-level-two-colour
                                       'start-open t 'end-closed t)))))
;; Renumbering *****************************************************
(defun enum-renumber-markers (level style alist prefix beg end)
  "Renumbers enumeration in the actual level. Returns number of markers
renumbered."
  (let ((counter 1))
    (save-excursion
      (beginning-of-buffer)
      (mapcar-extents
       (lambda (x)
         (let* ((beg (extent-start-position x))
                (diff (- (extent-end-position x) beg)))
           (goto-char beg)
           (delete-char diff)
           (enum-insert counter alist style "" prefix)
           (enum-make-extent beg (- (point) 1) level)
           (++ counter)))
       nil (current-buffer) beg end nil level))
    counter))
;; Little helpers **************************************************
(defmacro ++ (x)
  `(setq ,x (1+ ,x)))
(defmacro switch (x)
  `(setq ,x (+ 1 (mod ,x 2))))
;; Functions converting counter ************************************
(defun enum-arab-to-roman (arab &optional smallp)
  "Converts a arabian number to a roman number. arab is a decimal
number; smallp is a boolean value. true means return small roman. "
  (let* ((romans-alist
           '((1000 "M") (900 "CM") (500 "D") (400 "CD") (100 "C")(90 "XC")
             (50 "L") (40 "XL") (10 "X") (9 "IX") (5 "V") (4 "IV") (1 "I")))
         (arabs-list
           (mapcar 'car romans-alist))
         (romans
           (mapconcat (lambda (x)
                        (if (> (/ arab x) 0)
                          (prog1
                            (multstr
                             (cadr (assoc x romans-alist)) (/ arab x))
                            (setq arab (mod arab x)))))
                      arabs-list "")))
    (if smallp
      (downcase romans)
      romans)))
(defun enum-arab-to-smallroman (arab)
  "Converts a arabian number to a small roman number. "
  (enum-arab-to-roman arab t))
;; Functions converting string
(defun multstr (str multipl)
  "Returns mulipl copies of str. str == string, multipl = int. "
  (if (< multipl 2)
    str
    (concat str (multstr str (- multipl 1)))))
(defun enum-num-to-char (number str)
  "Maps a number to a character. 1 -> first char. 2 -> second char and so
on. If numbers exceed length of string it starts from the beginning. "
  (char-to-string
   (aref str (mod (- number 1) (length str)))))
(defun enum-width-2 (x)
  "The argument is placed in a field with width 2. "
  (format "%2s" x))
(defun enum-width-3 (x)
  "The argument is placed in a field with width 2. "
  (format "%3s" x))
(defun enum-width-4-bigroman (x)
  "The argument is placed in a field with width 4 and converted to a
big roman number. "
  (format "%4s" (enum-arab-to-roman x)))
(defun enum-width-4-smallroman (x)
  "The argument is placed in a field with width 4 and converted to a
small roman number. "
  (format "%4s" (enum-arab-to-smallroman x)))
;;; ****************************************************************
;;; Keybindings
;;; ****************************************************************
(define-key text-mode-map [(control return)] 'enum-insert-enum)
(define-key text-mode-map "\C-cec" 'enum-choose-style)
(define-key text-mode-map "\C-ced" 'enum-choose-reformat-style)
(define-key text-mode-map "\C-ces" 'enum-setup-indent-levels)
(define-key text-mode-map "\C-cer" 'enum-renumber-enums)
(define-key text-mode-map "\C-ceo" 'enum-reset-counter-one)
(define-key text-mode-map "\C-cet" 'enum-reset-counter-two)
(provide 'enum)
;;; enum.el ends here
