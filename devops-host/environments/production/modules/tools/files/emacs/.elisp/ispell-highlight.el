;;; ispell-highlight.el --- MS-Word like spell-error highlithing
;; 
;; Copyright (C) 1998-2000 Robert Fenk
;;
;; Author:      Robert Fenk
;; Status:      Tested with XEmacs 21.1.8 & VM 6.75
;; Keywords:    vm draft handling
;; X-URL:       http://www.robf.de/Hacking/elisp
;; X-RCS:       $Id: ispell-highlight.el,v 1.19 2004/05/18 21:18:59 fenk Exp $
;;

;;; Commentary:
;; 
;; 1) Type `M-x byte-compile-file "ispell-hl.el"' to byte compile
;;    this library and put it somewhere in your load-path (you can
;;    examine it with  `C-h v load-path').
;;
;; 2) Add the following lines to your .emacs file and remove the
;;    leading `;;>   '!
;;
;;>    ;; If you can't put ispell-highlight.el to the standard load-path,
;;>    ;; then you have to add the path to the place where you put your
;;>    ;; own Emacs libraries, e.g.  ~/elisp!
;;>    (setq load-path (cons (expand-file-name "~/elisp") load-path))
;;>    (autoload 'ispell-hl-minor-mode "ispell-highlight"
;;>      "Ispell highlight mode" t)
;;; 
;;  3) Start the mode with 'M-x ispell-hl-minor-mode' or with a hook
;;     function e.g.  for the LaTeX-mode I use this hook to activate
;;     some things:
;;
;;>    (defun rf-LaTeX-mode-hook () (interactive)
;;>      (ispell-change-dictionary "deutsch8")
;;>      (ispell-hl-minor-mode)
;;>      (auto-fill-mode t))
;;>    (add-hook 'LaTeX-mode-hook 'rf-LaTeX-mode-hook)
;;
;; For more information look at `ispell-hl-help'
;;
;;; ToDo List:
;; - The usual bug fixes of jet unknown bugs!
;; - A mechanism that performs `ispell-hl-buffer' in background?
;; - Find a way to underline the spell errors with a red "~~~~~~~",
;;   rather than the fancy background.  My first idea was to use a
;;   pixmap aligned to the baseline of the text, but that's not
;;   possible!?
;;

;;; Code:
(defconst ispell-hl-version "1.1")

(require 'ispell)

;;;###autoload
(defun ispell-hl-help ()
  "Ispell-highlight is another nice way th use the `ispell-mode'.

To activate it switch to function `ispell-hl-minor-mode'.

From now on every word that is not more than `ispell-hl-error-distance'
characters before point will be spell checked and if it is wrong it
will be highlighted with the `ispell-hl-error-face'.

Every time you change this word it will be spell checked again and
dehighlighted if it is right.

If you press the right mouse button over a highlighted word, a context
menu  with a list of possible corrections will pop up and if you choose
one, every occurrence of it will be corrected.  Corrections that begin
with a `?' are possible correct compositions of the derivative root
word, and if you select this one, it will be inserted in your private
dictionary.

Have a look at `ispell-hl-version' if you have any bug reports and
send me `Robert Fenk' a email with version information
`ispell-hl-version' and a short description of the errors(s), what
mode and actions caused it.

Customizable variables are `ispell-hl-error-distance' and
`ispell-hl-default-menu'.
The face used for highlighting may configured by
`ispell-hl-error-face'.

Two new keymaps, `ispell-hl-keymap' for highlighted errors and
`ispell-hl-minor-mode-keymap' for the minor mode might be changed
as well.
        
Bindings in ispell-hl-keymap:
\\{ispell-hl-keymap}
        
Bindings in ispell-hl-minor-mode-keymap:
\\{ispell-hl-minor-mode-keymap}"
  (interactive)
  (require 'hyper-apropos)
  (hyper-apropos-get-doc 'ispell-hl-help))

;;----------------------------------------------------------------------
;; Ispell options menu
(defun ispell-hl-options-menu ()
  "Create a Options submenu for Ispell."
  (interactive)
  (add-submenu
   '("Options")
   '("Ispell"
     ["Silently Save Personal Dictionary"
      (progn (if ispell-silently-savep
                 (setq ispell-silently-savep nil)
               (setq  ispell-silently-savep t)))
      :style toggle
      :selected ispell-silently-savep]
     ["Quietly Check Words"
      (progn (if ispell-quietly
                 (setq ispell-quietly nil)
               (setq  ispell-quietly t)))
      :style toggle
      :selected ispell-quietly]
     ["Only Check Words"
      (progn (if ispell-check-only
                 (setq ispell-check-only nil)
               (setq  ispell-check-only t)))
      :style toggle
      :selected ispell-quietly]
     ["Check Comments"
      (progn (if ispell-check-comments
                 (setq ispell-check-comments nil)
               (setq ispell-check-comments t)))
      :style toggle
      :selected ispell-check-comments]
     ["Highlight Spelling Minor Mode"
      (ispell-hl-minor-mode)
      :style toggle
      :selected ispell-hl-minor-mode]
     ["Spelling Minor Mode"
      (ispell-minor-mode)
      :style toggle
      :selected ispell-minor-mode]
     )
   "General Options")
  )

;;----------------------------------------------------------------------

;; Variable indicating that ispell minor mode is active.
;; (this mode should be local)
;;;###autoload
(defvar ispell-hl-minor-mode nil
  "Non-nil if Ispell minor mode is enabled.")
(make-variable-buffer-local 'ispell-hl-minor-mode)

;; Display some info in the mode-line
(or (assq 'ispell-hl-minor-mode minor-mode-alist)
    (setq minor-mode-alist
          (cons '(ispell-hl-minor-mode " HL-Spell")
                minor-mode-alist)))

;;;###autoload
(defun turn-on-ispell-hl ()
  "Turn on Ispell Highlight mode."
  (interactive "_")
  (ispell-hl-minor-mode 1))
  
;;;###autoload
(defun turn-off-ispell-hl ()
  "Turn off Ispell Highlight mode."
  (interactive "_")
  (ispell-hl-minor-mode -1)
  )
  
;;;###autoload
(defun ispell-hl-minor-mode (&optional arg)
  "Toggle Ispell Highlight mode.
With prefix ARG, turn Ispell Highlight mode on if arg is positive.
 
In Ispell Highlight mode, changing the buffer contens will spell
the words around the cursor and highlight miss-spelled ones!"
  (interactive "P")
  (setq ispell-hl-minor-mode
        (not (or (and (null arg) ispell-hl-minor-mode)
                 (<= (prefix-numeric-value arg) 0))))
  
  (make-local-hook 'before-change-functions)
  (make-local-hook 'after-change-functions)

  (if ispell-hl-minor-mode
      (progn
        (add-hook 'before-change-functions 'ispell-hl-before-check-word nil t)
        (add-hook 'after-change-functions 'ispell-hl-check-word nil t)
        )
    (progn
      (remove-hook 'before-change-functions 'ispell-hl-before-check-word t)
      (remove-hook 'after-change-functions 'ispell-hl-check-word t)
      (ispell-hl-buffer t)              ; remove highlighted errors
      ))
  
  (redraw-modeline))

;;----------------------------------------------------------------------

;; Bindings
(defvar ispell-hl-minor-mode-keymap
  (let ((map (make-keymap)))
    (define-key map [(control c) s p]
      'ispell-hl-prev-error)
    (define-key map [(control c) s n]
      'ispell-hl-next-error)
    (define-key map [(control c) s s]
      'ispell-hl-region)
    (define-key map [(control c) s e]
      'ispell-hl-dict-english)
    (define-key map [(control c) s d]
      'ispell-hl-dict-deutsch8)
    map)
  "*Keymap used for Ispell Highlight mode.")

(or (not (boundp 'minor-mode-map-alist))
    (assoc 'ispell-hl-minor-mode minor-mode-map-alist)
    (setq minor-mode-map-alist
          (cons (cons 'ispell-hl-minor-mode
                      ispell-hl-minor-mode-keymap)
                minor-mode-map-alist)))

;; Bindings to check every change in a highlighted spelling error
(defvar ispell-hl-keymap
  (let ((map (make-keymap)))
    (define-key map [(button3)]
      'ispell-hl-popup-error-menu)
    (define-key map [(previous)]
      'ispell-hl-prev-error)
    (define-key map [(prior)]
      'ispell-hl-prev-error)
    (define-key map [(next)]
      'ispell-hl-next-error)
;    (define-key map [(insert)]
;      'ispell-hl-insert-word-at-point)
    map)
  "*Keymap used for editing highlighted spelling errors.")

;;----------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-dict-english ()
  "Change dictionary to \"american\"."
  (interactive "_")
  (ispell-change-dictionary "american"))

;;;###autoload
(defun ispell-hl-minor-mode-english ()
  (interactive)
  (setq ispell-local-dictionary "american")
  (ispell-hl-minor-mode 1)
  (ispell-hl-dict-english))

;;;###autoload
(defun ispell-hl-dict-deutsch8 ()
  "Change dictionary to \"deutsch8\"."
  (interactive "_")
  ;(ispell-change-dictionary "german-new8")
  (ispell-change-dictionary "deutsch8")
  )

;;----------------------------------------------------------------------

(make-face 'ispell-hl-error-face
           "Face to use for highlighting spelling errors.")

(set-face-foreground    'ispell-hl-error-face "red3")
(set-face-underline-p   'ispell-hl-error-face t)

;;----------------------------------------------------------------------
(defvar ispell-hl-menu
  '("Ispell Commands" :filter ispell-hl-error-menu)
  "*Menu for highlighted spelling errors.
Don't change this variabel, bau have a look at the variable
`ispell-hl-default-menu'."
  )

(defvar ispell-hl-default-menu
  '(["Insert"
     (progn (process-send-string ispell-process
                (concat "*" ispell-hl-word "\n"))
            (setq ispell-pdict-modified-p t)
            (ispell-hl-dehighlight-word ispell-hl-word))
     t]
    ["Downcase & Insert"
     (progn (process-send-string ispell-process
                (concat "*" (downcase ispell-hl-word) "\n"))
            (setq ispell-pdict-modified-p t)
            (ispell-hl-dehighlight-word ispell-hl-word))
     t]
    "------"
    ["Accept"
     (progn (process-send-string ispell-process
                (concat "@" ispell-hl-word "\n"))
            (ispell-hl-dehighlight-word ispell-hl-word))
     t]
    ["Accept & Local Insert"
     (progn (ispell-add-per-file-word-list ispell-hl-word)
            (process-send-string ispell-process
                (concat "@" ispell-hl-word "\n"))
            (ispell-hl-dehighlight-word ispell-hl-word))
     t]
    ["Dehighlight"
     (ispell-hl-dehighlight-word ispell-hl-word)
     t]
    "------"
    ["Save  Dictionary"
     (progn (ispell-pdict-save ispell-silently-savep))
     t]
    ["Help for this mode"
     (ispell-hl-help)
     t]
    )
  "*The default menu items.
They will be appended to the list of possible corrections for a
spelling error.

  Menu-item:              Action:
Insert:                 Accept word and insert into private dictionary.
Downcase & Insert:      Like \"Insert\", but the word is down-cased first.
Accept:                 Accept word for this session.
Accept & Local Insert:  Accept word and place in `buffer-local dictionary'.
Save  Dictionary:       Saves your private dictionary.
Help:                   Shows the help for ispell-highlight.
        
You can change it if you like other commands ..."
  )

(defvar ispell-hl-error-distance 1
  "*Threshold distance which triggers checking of a word.")

(defvar ispell-hl-check-word-p nil
  "*Function providing per-mode customization over which words are flyspelled.
Returns t to continue checking, nil otherwise.
Flyspell mode sets this variable to whatever is the `flyspell-mode-predicate'
property of the major mode name.")

;;----------------------------------------------------------------------
(defvar ispell-hl-check-word t
  "Non-nil if futhter checking is necessary.")
(defvar ispell-hl-word nil
  "The highlighted word with a spelling error under the pointer.")
(defvar ispell-hl-word-extent nil
  "The extent of the highlighted spelling error under the pointer.")
(defvar ispell-hl-word-start 0
  "The start of the highlighted spelling error under the pointer.")
(defvar ispell-hl-word-end 0
  "The end of the highlighted spelling error under the pointer.")

;;----------------------------------------------------------------------
(defun ispell-hl-beep ()
  "Called in order to signal a spelling error.")
;;----------------------------------------------------------------------
(defun ispell-hl-error-menu (menu)
  "Create the context menu for highlighted spelling errors.
To customise the context MENU, see the variable
`ispell-hl-default-menu' for more information."
  (let ((poss nil) (iposs nil)
        (word nil)
        (replace-fun 'ispell-hl-replace-errors)
        (insert-fun  'ispell-hl-insert-word))

    (setq word ispell-hl-word)
    
    (process-send-string ispell-process "%\n") ; put in verbose mode
    (process-send-string ispell-process (concat "^" word "\n"))
    ;; wait until ispell has processed word
    (while (progn
             (accept-process-output ispell-process)
             (not (string= "" (car ispell-filter)))))

    ;;(process-send-string ispell-process "!\n") ;back to terse mode.
    (setq ispell-filter (cdr ispell-filter))
    (if (listp ispell-filter)
        (setq poss (ispell-parse-output (car ispell-filter))))
    
    (cond ((eq poss t)
           (or ispell-quietly
               (message "%s is correct" (funcall ispell-format-word word))))
          ((stringp poss)
           (or ispell-quietly
               (message "%s is correct because of root %s"
                        (funcall ispell-format-word word)
                        (funcall ispell-format-word poss))))
          ((null poss) (setq menu '(["Error in ispell process" nil t])))
          (t
           (setq iposs (nth 3 poss))
           (setq poss (nth 2 poss))
           (if poss
               (progn
                 (while poss
                   (setq menu (cons (vector (car poss)
                                            (list replace-fun (car poss))
                                            t)
                                    menu))
                   (setq poss (cdr poss)))
                 (setq menu (append menu '("--:doubleLine")))
                 )
             )
           (if iposs
               (progn
                 (setq menu (cons "--:doubleLine" menu))
                 (while iposs
                   (setq menu (cons (vector (concat "? " (car iposs))
                                            (list insert-fun (car iposs))
                                            t)
                                    menu))
                   (setq iposs (cdr iposs)))
                 )
             )
           ))

    (append menu ispell-hl-default-menu)
    ))

;;----------------------------------------------------------------------
(defun ispell-hl-replace-errors (newword &optional word from to)
  "Dehighlight and replace by NEWWORD all highlighted errors of WORD.
This is only done in the region delimited by FROM and TO."
  (interactive "*sNew word?: \nsWord?: \nr")
  (if (not word) (setq word ispell-hl-word))
  (if (not from) (setq from (point-min)))
  (if (not to)   (setq to   (point-max)))

  (setq ispell-hl-check-word nil)
  (ispell-hl-mapcar-errors
   (function
    (lambda (x)
      (save-excursion
        (let ((start (extent-start-position x))
              (end   (extent-end-position   x)))
          (if (string= word (buffer-substring start end))
              (progn (ispell-hl-dehighlight-error x)
                     (goto-char start)
                     (delete-region start end)
                     (insert newword)))))))
   from to)
  (setq ispell-hl-check-word t)
  )

;;----------------------------------------------------------------------
(defun ispell-hl-is-word-highlighted (x)
  "Return t if extent X has ispell-hl-error-face."
  (if (and x (extent-live-p x))
      (extent-property x 'ispell-hl-error)
    nil))

;;----------------------------------------------------------------------
(defun ispell-hl-insert-word (&optional word)
  "Insert WORD into private dictionary and dehighlight errors."
  (interactive "*sWord? ")
  (setq word (replace-in-string word "[+-]" ""))
  (process-send-string ispell-process (concat "*" word "\n"))
  (if (not ispell-quietly) 
      (message "Word `%s' inserted into private dictionary." word))
  (setq ispell-pdict-modified-p t)
  (ispell-hl-dehighlight-word word))

;;----------------------------------------------------------------------
(defun ispell-hl-insert-word-at-point ()
  (interactive)
  (let ((x (ispell-hl-get-extent)))
    (ispell-hl-insert-word (buffer-substring (extent-start-position x)
                                             (extent-end-position   x))))
  (ispell-hl-next-error))

;;----------------------------------------------------------------------
(defun ispell-hl-popup-error-menu (event)
  "Popup a contex menu with a list of possible correction choices.
The `ispell-hl-default-menu' will pop up, when the right mouse button is
pressed over a highlighted spelling error.  The point of EVENT will be
used to locate the highlighted spelling error.

Normally bound in `ispell-hl-keymap' to button-3."
  (interactive "e")
  (let ((x nil))
    (if event
        (setq x (extent-at (event-point event)
                           (current-buffer) 'face nil 'at))
      )

    (if (ispell-hl-is-word-highlighted x)
        (progn
          (setq ispell-hl-word-extent x)
          (setq ispell-hl-word-start (extent-start-position x))
          (setq ispell-hl-word-end   (extent-end-position x))
          (setq ispell-hl-word
                (buffer-substring ispell-hl-word-start
                                  ispell-hl-word-end))
          (popup-menu ispell-hl-menu)
          )
      (progn
        (setq ispell-hl-word-extent nil)
        (setq ispell-hl-word nil)
        (message "There is no highlighted spelling error!")
        (ispell-hl-beep)
        ))))

;;----------------------------------------------------------------------
(defun ispell-hl-dehighlight-word (word &optional from to)
  "Dehighlights all highlighted spelling errors of WORD.
Non-nil values for FROM and TO specify the region for this action."
  (interactive "*sWord?: \nr")
  (if (not from) (setq from (point-min)))
  (if (not to)   (setq to   (point-max)))

  (ispell-hl-mapcar-errors
   (function
    (lambda (x)
      (if (string= word
                   (buffer-substring (extent-start-position x)
                                     (extent-end-position x)))
          (ispell-hl-dehighlight-error x))))
   from to))

(defun ispell-hl-before-check-word (from to)
  "If we split a word there are two words to spell!
FROM and TO delimit the word."
  (interactive "*")
  (save-excursion
    (setq ispell-hl-word-start from)
    (setq ispell-hl-word-end   to)
    (setq ispell-hl-word       (buffer-substring from to))))

;;----------------------------------------------------------------------
(defun ispell-hl-check-word (from to oldlen)
  "Check the word delimited by FROM and TO which had the length OLDLEN.

If point is behind a highlighted spelling error or the typed character
is not a word constituentit then the word will be spell checked.

In `TeX-mode' words starting with `\\' are not checked"
  (interactive "*")
  (if (or (null ispell-hl-check-word-p) (funcall ispell-hl-check-word-p))
      (let ((word "") (lead "") (start nil) (end nil)
            (cursor (point))
            (x (extent-at (point) (current-buffer) 'face nil 'at))
            (ispell-casechars (ispell-get-casechars))
            (ispell-not-casechars (ispell-get-not-casechars))
            (ispell-otherchars (ispell-get-otherchars))
            (ispell-many-otherchars-p (ispell-get-many-otherchars-p))
            (word-regexp))
        
        (setq word-regexp (concat ispell-casechars
                                  "+\\(" ispell-otherchars "?"
                                  ispell-casechars
                                  "+\\)"
                                  (if ispell-many-otherchars-p
                                      "*" "?")))
    
        (setq word (buffer-substring from to))
        ;;    (message "2>%s<%s<%s<%s<%s!" word from to oldlen (length word))

        ;; If we insert some kind of text with white spaces, maybe a word
        ;; has been separated and the two new parts of it will be spell
        ;; checked
        (if (or (> (length word) 1)
                (and (= (length word) 1)
                     (string-match ispell-not-casechars word)))
            (save-excursion
;         (ispell-hl-region from to) ;; Check pasted text ?
              (goto-char (- from 1))
              (ispell-hl-check-word (point) (point) 0)))

    
        (if (and ispell-hl-check-word
                 (or (ispell-hl-is-word-highlighted x)
                     (or (= from to)
                         (and (> (length word) 0)
                              (string-match ispell-not-casechars word)))))
            (save-excursion
              ;; if word is highlighted, then we move to the end of the word
              ;; find the word
              (while (and (not (bobp)) (looking-at ispell-not-casechars))
                (backward-char 1))
              (while (and (not (bobp)) (looking-at ispell-casechars))
                (backward-char 1))
              (while (and (not (bobp)) (looking-at ispell-otherchars))
                (backward-char 1))
              (while (and (not (bobp)) (looking-at ispell-casechars))
                (backward-char 1))
          
              (setq start (re-search-forward
                           (concat "\\(\\W\\|^\\)\\(" word-regexp "\\)+")
                           (point-max) t 1))
          
              ;; if there was a word get it, and it's start and end
              (if start
                  (progn
                    (setq lead  (match-string 1)
                          start (match-beginning 2)
                          end   (match-end 2)
                          word  (match-string 2))
                    (if (and ispell-hl-error-distance
                             (>= (+ end ispell-hl-error-distance) cursor))
                        (ispell-hl-do-a-check lead word start end)
                      )))
              ))
        )))

;;----------------------------------------------------------------------
(defun ispell-hl-do-a-check (lead word start end)
  "Perform a spell check on WORD delimited by START and END."
  (cond
   ;; skip latex commands 
   ((and (string-match "TeX" mode-name)
              (string= "\\" lead))
         (if (not ispell-quietly)
             (message "'%s' seems to be a TeX command!"word)))
   ;; skip all mail headers except subject 
   ((and (string-match "Mail" mode-name)
         (not (or (save-excursion
                    (re-search-backward mail-header-separator
                                        (point-min) t))
                  (save-excursion
                    (beginning-of-line)
                    (looking-at "Subject:")))))
    (if (not ispell-quietly)
        (message "Mail headers are not spell checked!")
      ))
   ;; the default is to check the work ...
   (t (ispell-hl-word word start end))))
  
  
;; Without this pending-delete won't work!
(put 'ispell-hl-check-word 'pending-delete t)

;;----------------------------------------------------------------------
(defun ispell-hl-error (from to)
  "Highlight the region delimited by FROM and TO as a spelling-error."
  (interactive "r")
  (let ((x (make-extent from to (current-buffer))))
    (set-extent-keymap x ispell-hl-keymap)
    (set-extent-property x 'pointer selection-pointer-glyph)
    (set-extent-property x 'duplicable t)
    (set-extent-property x 'unique t)
    (set-extent-property x 'start-open t)
    (set-extent-property x 'end-closed t)
    (set-extent-priority x 1000)
    (set-extent-property x 'ispell-hl-error t)
    (set-extent-face x 'ispell-hl-error-face)))

;;----------------------------------------------------------------------
(defun ispell-hl-get-extent (&optional point)
  "Dehighlight spelling-error at point respectively dehighlight extent X."
  (interactive "")
  (extent-at (or point (point)) (current-buffer) 'ispell-hl-error nil 'at))

;;----------------------------------------------------------------------
(defun ispell-hl-dehighlight-error (x)
  "Dehighlight spelling-error at point respectively dehighlight extent X."
  (interactive (list nil))
  (if (ispell-hl-is-word-highlighted (or x (ispell-hl-get-extent (point))))
      (delete-extent x)
    (message "There is no highlighted spelling error!")))

;;----------------------------------------------------------------------
(defun ispell-hl-mapcar-errors (fun from to)
  "Apply function FUN on all the highlighted spelling errors FROM TO.
The function will get one argument, the extent of the highlighted
spelling error!"
  (mapcar-extents fun                   ; FUNCTION
                  nil                   ; PREDICATE
                  (current-buffer)      ; BUFFER-OR-STRING
                  from to               ; FROM TO
                  'start-in-region      ; FLAGS
                  'ispell-hl-error      ; PROPERTY
                  t                     ; VALUE
                  ))

;;----------------------------------------------------------------------
(defun ispell-hl-word (&optional word start end quietly continue)
  "This is the ispell-highlight version of `ispell-word'.

Check spelling of WORD under or before the cursor.  If the word is not
found in dictionary, display possible corrections in a window allowing
you to choose one.  The word is delimited by START and END.

Checking will be performed without noise if QUIETLY is non-nil.
With a prefix argument (or if CONTINUE is non-nil),
resume interrupted spell-checking of a buffer or region.

Word syntax described by `ispell-dictionary-alist' (which see).

This will check or reload the dictionary.  Use \\[ispell-change-dictionary]
or \\[ispell-region] to update the Ispell process."
  (interactive)
  (ispell-accept-buffer-local-defs)     ; use the correct dictionary
  (let (poss)                           ; possible corrections
    (cond ((interactive-p)
           (setq word (ispell-get-word nil)
                 start (car (cdr word))
                 end (car (cdr (cdr word)))
                 word (car word))))
    ;; now check spelling of word.
      (or ispell-quietly
          (message "Checking spelling of '%s' ..."
                   (funcall ispell-format-word word)))
      (process-send-string ispell-process "%\n") ; put in verbose mode
      (process-send-string ispell-process (concat "^" word "\n"))
      ;; wait until ispell has processed word
      (while (progn
               (accept-process-output ispell-process)
               (not (string= "" (car ispell-filter)))))

      (setq ispell-filter (cdr ispell-filter))
      (if (listp ispell-filter)
          (setq poss (ispell-parse-output (car ispell-filter))))

      (ispell-hl-mapcar-errors 'ispell-hl-dehighlight-error start end)

      (when (and (boundp 'enable-completion)
                 enable-completion (> (length word) 3)
                 (or (eq poss t) (stringp poss)))
        (add-completion-to-head word)
        (message "%s added to completion list" word))
      
      (cond ((eq poss t)
             (or ispell-quietly
                 (message "%s is correct" (funcall ispell-format-word word))))
            ((stringp poss)
             (or ispell-quietly
                 (message "%s is correct because of root %s"
                          (funcall ispell-format-word word)
                          (funcall ispell-format-word poss))))
            ((null poss)
             (message "Error in ispell process"))
            (t
             (if ispell-hl-minor-mode (ispell-hl-error start end))
             (ispell-hl-beep)
             )
            )
      

      (ispell-pdict-save ispell-silently-savep)
      (if ispell-quit (setq ispell-quit nil))))


;;----------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-region (reg-start reg-end &optional recheckp shift)
  "Interactively check a region for spelling errors.
Return nil if spell session is quit, otherwise returns shift offset
amount for last line processed.
The regions is delimited by REG-START and REG-END.  A non-nil RECHECKP
indicates that the choices buffer is still there and SHIFT might
specify a predefined shift offset."
  (interactive "r\nP")
  (ispell-hl-mapcar-errors 'ispell-hl-dehighlight-error reg-start reg-end)
  (if (not recheckp)
      (ispell-accept-buffer-local-defs)) ; set up dictionary, local words, etc.
  (unwind-protect
      (save-excursion
        (message "Spell checking %s using %s dictionary..."
                 (if (and (= reg-start (point-min)) (= reg-end (point-max)))
                     (buffer-name) "region")
                 (or ispell-dictionary "default"))
        ;; Returns cursor to original location.
        (save-window-excursion
          (goto-char reg-start)
          (let ((transient-mark-mode)
                (case-fold-search case-fold-search)
                (skip-region-start (make-marker))
                (skip-regexp (ispell-begin-skip-region-regexp))
                (skip-alist ispell-skip-region-alist)
                key)
            (if (eq ispell-parser 'tex)
                (setq case-fold-search nil
                      skip-alist
                      (append (car ispell-tex-skip-alists)
                              (car (cdr ispell-tex-skip-alists))
                              skip-alist)))
            (let (message-log-max)
              (if ispell-quietly
                  (ispell-hl-beep)
                (message "searching for regions to skip")))
            (if (re-search-forward skip-regexp reg-end t)
                (progn
                  (setq key (buffer-substring-no-properties
                             (match-beginning 0) (match-end 0)))
                  (set-marker skip-region-start (- (point) (length key)))
                  (goto-char reg-start)))
            (let (message-log-max)
              (message "Continuing spelling check using %s dictionary..."
                       (or ispell-dictionary "default")))
            (set-marker ispell-region-end reg-end)
            (while (and (not ispell-quit)
                        (< (point) ispell-region-end))
              ;; spell-check region with skipping
              (if (and (marker-position skip-region-start)
                       (<= skip-region-start (point)))
                  (progn
                    (ispell-skip-region key) ; moves pt past region.
                    (setq reg-start (point))
                    (if (and (< reg-start ispell-region-end)
                             (re-search-forward skip-regexp
                                                ispell-region-end t))
                        (progn
                          (setq key (buffer-substring-no-properties
                                     (car (match-data))
                                     (car (cdr (match-data)))))
                          (set-marker skip-region-start
                                      (- (point) (length key)))
                          (goto-char reg-start))
                      (set-marker skip-region-start nil))))
              (setq reg-end (if (marker-position skip-region-start)
                                (min skip-region-start ispell-region-end)
                              (marker-position ispell-region-end)))
              (let* ((start (point))
                     (end (save-excursion (end-of-line) (min (point) reg-end)))
                     (string (ispell-get-line start end reg-end "")))
                (setq end (point))      ; "end" tracks region retrieved.
          ;;-- changes start -----------------------------------------
          (if string                    ; there is something to spell!
              (let (poss)
                ;; send string to spell process and get input.
                (process-send-string ispell-process string)
                (while (progn
                         (accept-process-output ispell-process)
                         ;; Last item of output contains a blank line.
                         (not (string= "" (car ispell-filter)))))
                ;; parse all inputs from the stream one word at a time.
                ;; Place in FIFO order and remove the blank item.
                (setq ispell-filter (nreverse (cdr ispell-filter)))
                (while (and (not ispell-quit) ispell-filter)
                  (setq poss (ispell-parse-output (car ispell-filter)))
                  (if (listp poss)      ; spelling error occurred.
                      (let* ((word-start (+ start -1
                                            (car (cdr poss))))
                             (word-end (+ word-start
                                          (length (car poss))))
                             )
                        (ispell-hl-error word-start word-end)
                        (sit-for 0) ; Perform redisplay
                        (redisplay-frame)
                        ))
                  ;; finished with line!
                  (setq ispell-filter (cdr ispell-filter)))))
          ;;-- changes end -------------------------------------------
                (goto-char end)))))
        (if ispell-quit
            nil
          (or shift 0)))
    ;; protected
    (if (and (not (and recheckp ispell-keep-choices-win))
             (get-buffer ispell-choices-buffer))
        (kill-buffer ispell-choices-buffer))
    (if ispell-quit
        (progn
          ;; preserve or clear the region for ispell-continue.
          (if (not (numberp ispell-quit))
              (set-marker ispell-region-end nil)
            ;; Ispell-continue enabled - ispell-region-end is set.
            (goto-char ispell-quit))
          ;; Check for aborting
          (if (and ispell-checking-message (numberp ispell-quit))
              (progn
                (setq ispell-quit nil)
                (error "Message send aborted")))
          (if (not recheckp) (setq ispell-quit nil)))
      (if (not recheckp) (set-marker ispell-region-end nil))
      ;; Only save if successful exit.
      (ispell-pdict-save ispell-silently-savep)
      (if ispell-quietly
          (ispell-hl-beep)
        (message "Spell-checking done")))))


;;-----------------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-buffer (&optional arg)
  "Highlight all spelling errors in buffer.
With a prefix ARG, dehighlights all spelling errors in buffer."
  (interactive "P")
  (if arg (ispell-hl-mapcar-errors 'ispell-hl-dehighlight-error
                                          (point-min) (point-max))
    (ispell-hl-region (point-min) (point-max))))

;;-----------------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-paragraph (&optional arg)
  "Highlight all spelling errors in buffer.
With a prefix ARG, dehighlights all spelling errors in buffer."
  (interactive "P")
  (mark-paragraph)
  (if arg (ispell-hl-mapcar-errors 'ispell-hl-dehighlight-error
                                          (point-min) (point-max))
    (ispell-hl-region (mark) (point))))

;;-----------------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-prev-error ()
  "Moves point to previous highlighted spelling error."
  (interactive)
  (let ((pos nil))
    (ispell-hl-mapcar-errors
     (function
      (lambda (x)
        (cond ((>= (point) (extent-end-position x))
               (setq pos (- (extent-end-position x) 1))
               ))
        )) (point-min) (- (point) 1))
    
    (cond (pos (goto-char pos))
          (t (message "No previous spelling error!")
             (ispell-hl-beep)
             ))))

;;-----------------------------------------------------------------------------
;;;###autoload
(defun ispell-hl-next-error ()
  "Moves point to next highlighted spelling error."
  (interactive)
  (let ((pos nil))
    (ispell-hl-mapcar-errors
     (function
      (lambda (x)
        (cond ((and (not pos) (< (point) (extent-start-position x)))
               (setq pos (extent-start-position x))
               ))
        )) (point) (point-max))
    
    (cond (pos (goto-char pos))
          (t (message "No next spelling error!") (ispell-hl-beep)))))

;;-----------------------------------------------------------------------------
(provide 'ispell-highlight)

;;; ispell-highlight.el ends here
