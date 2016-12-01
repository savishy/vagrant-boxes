;;; top.el --- run "top" to display information about processes 

;; Author: Tom Wurgler, Bill Benedetto <twurgler@goodyear.com>
;; Created: 1/19/98
;; Keywords: extensions, processes

;; top.el is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; top.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This code sets up a buffer to handle running the "top" program written
;; by William LeFebvre.  "top" is avaiable at ftp.groupsys.com:/pub/top
;; When you exit "top", the sentinel kills the buffer.

;
; $Id: top.el,v 1.2 1998-01-27 12:00:04-05 t901353 Exp $
;
; $Log: top.el,v $
; Revision 1.2  1998-01-27 12:00:04-05  t901353
; changed arg to concat to be string and not integer.
;
; Revision 1.1  1998-01-27 09:54:29-05  t901353
; Initial revision
;
;;; Code:

(defvar top-command "/usr/local/bin/top"
  "*Command that runs the correct 'top' version for your machine.")
(defvar top-delay-seconds 5
  "*Seconds to delay between updates of 'top'. Default is 5 seconds.")
(defvar top-display-active nil
  "*If t, display only active processes by default.
If nil, include the inactive ones too.")

(defvar top-number-of-processes-to-show nil
  "*Number of processes to show in the 'top' list.  If nil, fills the
window.")

(defvar top-original-buffer nil
  "The buffer being visited when 'top' was started.")

(defun top ()
  "Runs 'top' in a terminal buffer."
  (interactive)
  (setq top-original-buffer (buffer-name))
  (if (get-buffer "*top*")
      (kill-buffer "*top*"))
  (let ((tnopts
  (if top-number-of-processes-to-show 
      top-number-of-processes-to-show 
    (- (window-height) 8))))
    (set-buffer (make-term "top" top-command
      (if top-display-active "-I" nil)
      (concat "-s" (int-to-string top-delay-seconds))
      (int-to-string tnopts))))
  (term-mode)
  (term-char-mode)
  (switch-to-buffer "*top*"))
 
(defun top-sentinel ()
  (set-process-sentinel (get-buffer-process "*top*")
   (function top-clear-sentinel)))

(defun top-clear-sentinel (proc str)
  (if (get-buffer "*top*")
      (progn
 (switch-to-buffer top-original-buffer)
 (kill-buffer "*top*"))))
      ; 
(add-hook 'term-exec-hook 'top-sentinel)
