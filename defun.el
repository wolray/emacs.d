(defmacro cycle-values (var values)
  `(let ((i (cl-position ,var ,values)))
     (setq ,var (elt ,values (if (and i (< (1+ i) (length ,values))) (1+ i) 0)))))

(defun c-beginning-of-line ()
  (interactive)
  (if (or (bolp) (> (current-column) (f-beginning-of-line 1)))
      (f-beginning-of-line)
    (beginning-of-line))
  (hyper-mode 1))

(defun c-byte-compile ()
  (interactive)
  (let ((file (buffer-name)))
    (and (eq major-mode 'emacs-lisp-mode)
	 (file-exists-p file)
	 (if (not (file-exists-p (concat file "c")))
	     (and (y-or-n-p "Byte compile this file?") (byte-compile-file file))
	   (and (y-or-n-p "Byte recompile all?")
		(byte-recompile-directory
		 (concat default-directory "..//")))))))

(defun c-clear-or-revert-buffer ()
  (interactive)
  (unless (minibufferp)
    (if (not (get-buffer-process (current-buffer)))
	(revert-buffer t t)
      (symbol-overlay-remove-all)
      (delete-region (point-min) (point-max))
      (comint-send-input)
      (goto-char (point-min))
      (kill-line))))

(defun c-copy-buffer ()
  (interactive)
  (unless (minibufferp)
    (f-delete-trailing-whitespace)
    (kill-ring-save (point-min) (point-max))
    (message "Current buffer saved")))

(defun c-cycle-paren-shape ()
  (interactive)
  (let ((paren-shapes '((?\( ?\[ ?\])
                        (?\[ ?\( ?\))))
        (pt (point)))
    (unless (eq ?\( (char-syntax (char-after)))
      (backward-up-list))
    (pcase (assq (char-after) paren-shapes)
      (`(,_ ,open ,close)
       (save-excursion (forward-sexp) (delete-char -1) (insert close))
       (delete-char 1)
       (insert open)))
    (goto-char pt)))

(defun c-cycle-search-whitespace-regexp ()
  (interactive)
  (unless (minibufferp)
    (cycle-values search-whitespace-regexp '("\\s-+" ".*?"))
    (message "search-whitespace-regexp: \"%s\"" search-whitespace-regexp)))

(defun c-delete-pair ()
  (interactive)
  (unless (eq ?\( (char-syntax (char-after)))
    (backward-up-list))
  (save-excursion (forward-sexp) (delete-char -1))
  (delete-char 1))

(defun c-dired ()
  (interactive)
  (switch-to-buffer (dired-noselect default-directory))
  (revert-buffer))

(defun c-each ()
  (interactive)
  (when (minibufferp)
    (insert (if (eq last-command this-command) "[]" "\\,(f-each )"))
    (backward-char)))

(defun c-incf ()
  (interactive)
  (when (minibufferp)
    (insert "\\,(f-incf)")
    (backward-char)))

(defun c-indent-paragraph ()
  (interactive)
  (unless (or (minibufferp) buffer-read-only)
    (save-excursion
      (mark-paragraph)
      (indent-region (region-beginning) (region-end)))
    (and (bolp) (f-skip-chars))))

(defun c-insert-arrow-1 ()
  (interactive)
  (let (p)
    (save-excursion
      (backward-sexp)
      (cond ((looking-at-p "<-")
	     (insert "->") (delete-char 2))
	    ((looking-at-p "->")
	     (insert "<-") (delete-char 2))
	    (t (setq p t))))
    (when p (insert "->"))))

(defun c-insert-arrow-2 ()
  (interactive)
  (insert "=>"))

(defun c-insert-at-eol ()
  (interactive)
  (end-of-line)
  (hyper-mode 0))

(defun c-insert-space ()
  (interactive)
  (insert ? ))

(defun c-isearch-done ()
  (interactive)
  (isearch-done))

(defun c-isearch-forward ()
  (interactive)
  (if (use-region-p)
      (let* ((beg (region-beginning))
	     (text (buffer-substring-no-properties beg (region-end))))
	(setq mark-active nil)
	(goto-char beg)
	(isearch-forward nil t)
	(isearch-yank-string text))
    (call-interactively 'isearch-forward)))

(defun c-isearch-yank ()
  (interactive)
  (isearch-yank-string (current-kill 0)))

(defun c-kill-buffer-other-window ()
  (interactive)
  (other-window 1)
  (kill-this-buffer)
  (other-window -1))

(defun c-kill-region ()
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (let ((co (current-column)))
      (kill-whole-line)
      (move-to-column co))))

(defun c-kill-ring-save (beg end)
  (interactive
   (if (use-region-p) (list (region-beginning) (region-end))
     (list (f-beginning-of-line 0) (line-end-position))))
  (kill-ring-save beg end)
  (or (minibufferp) (message "Current line saved")))

(defun c-kill-sexp ()
  (interactive)
  (let ((pt (point))) (C-M-f) (kill-region pt (point))))

(defun c-kmacro-end-or-call-macro (arg)
  (interactive "P")
  (unless (minibufferp)
    (cond (defining-kbd-macro (kmacro-end-macro arg))
	  ((use-region-p)
	   (apply-macro-to-region-lines (region-beginning) (region-end)))
	  (t (kmacro-call-macro arg t)))))

(defun c-kmacro-start-macro (arg)
  (interactive "P")
  (unless (minibufferp)
    (setq defining-kbd-macro nil)
    (kmacro-start-macro arg)))

(defun c-open-folder ()
  (interactive)
  (w32-shell-execute
   "open" "explorer"
   (if buffer-file-name
       (concat "/e,/select," (convert-standard-filename buffer-file-name))
     (convert-standard-filename default-directory))))

(defun c-phone-test ()
  (interactive)
  (let* ((seq [1 3 5 6 7 8 11 13 16 17 18 21 23 24 25 29 30 31 32 33 35 37 38 39 40 41 45 47 48 52 55 57 58 61 63 65 67 68 73 81])
         (s (thing-at-point 'symbol))
         (n (string-to-number s))
         (len (length s))
         (i 0)
         (sum 0))
    (while (< i len)
      (cl-incf sum (string-to-number (substring s i (cl-incf i)))))
    (setq mod (% n 80))
    (message "%d (%s), %d (%s)"
             mod (if (cl-find mod seq) "y" "n")
             sum (if (cl-find sum seq) "y" "n"))))

(defun c-query-replace ()
  (interactive)
  (unless (minibufferp)
    (if (use-region-p) (f-query-replace-region (region-beginning) (region-end))
      (setq mark-active nil)
      (call-interactively 'query-replace))))

(defun c-reload-current-mode ()
  (interactive)
  (unless (minibufferp)
    (symbol-overlay-remove-all)
    (funcall major-mode)))

(defun c-rename-file-and-buffer ()
  (interactive)
  (let ((old buffer-file-name) new)
    (when (and old (not (buffer-modified-p)))
      (setq new (read-file-name "Rename: " old))
      (and (file-exists-p new) (user-error "File already exists"))
      (rename-file old new)
      (set-visited-file-name new t t))))

(defun c-set-or-exchange-mark (arg)
  (interactive "P")
  (if (use-region-p) (exchange-point-and-mark)
    (set-mark-command arg)))

(defun c-sort-text ()
  (interactive)
  (unless (minibufferp)
    (let ((pt (point)) (skip-chars-regexp "\n"))
      (if (use-region-p)
	  (save-restriction
	    (let ((beg (region-beginning))
		  (end (region-end))
		  recfun)
	      (goto-char beg)
	      (setq recfun (if (bolp) (cons 'forward-line 'end-of-line)
			     (f-skip-chars)
			     (cons 'f-skip-chars 'forward-sexp)))
	      (narrow-to-region beg end)
	      (sort-subr nil (car recfun) (cdr recfun))))
	(when (y-or-n-p "Sort all paragraphs?")
	  (goto-char (point-min))
	  (sort-subr nil 'f-skip-chars 'forward-paragraph)))
      (goto-char pt))))

(defun c-switch-to-next-buffer ()
  (interactive)
  (f-switch-to-buffer 1))

(defun c-switch-to-prev-buffer ()
  (interactive)
  (f-switch-to-buffer 0))

(defun c-switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun c-tab ()
  (interactive)
  (if (or (minibufferp)
	  buffer-read-only
	  (region-active-p)
	  (not (looking-at-p "\\_>"))
          just-tab)
      (TAB)
    (call-interactively 'hippie-expand)))
(defun c-toggle-tab ()
  (interactive)
  (setq just-tab (not just-tab))
  (message "just-tab: %s" just-tab))
(defvar-local just-tab nil)

(defun c-toggle-comment (beg end)
  (interactive
   (if (use-region-p) (list (region-beginning) (region-end))
     (list (line-beginning-position) (line-beginning-position 2))))
  (or (minibufferp) (comment-or-uncomment-region beg end)))

(defun c-toggle-frame ()
  (interactive)
  (cycle-values frame-alpha '(100 70))
  (set-frame-parameter (selected-frame) 'alpha frame-alpha))
(defvar frame-alpha 100)

(defun c-transpose-lines-down ()
  (interactive)
  (unless (minibufferp)
    (let ((pt (point)) (co (current-column)))
      (f-prepare-transpose)
      (end-of-line 2)
      (if (eobp) (goto-char pt)
	(transpose-lines 1)
	(forward-line -1)
	(move-to-column co)))))

(defun c-transpose-lines-up ()
  (interactive)
  (unless (minibufferp)
    (let ((co (current-column)))
      (f-prepare-transpose)
      (beginning-of-line)
      (unless (or (bobp) (eobp))
	(forward-line)
	(transpose-lines -1)
	(beginning-of-line 0))
      (move-to-column co))))

(defun c-transpose-paragraphs-down ()
  (interactive)
  (unless (minibufferp)
    (let (p)
      (f-prepare-transpose)
      (backward-paragraph)
      (and (bobp) (setq p t) (newline))
      (forward-paragraph)
      (or (eobp) (transpose-paragraphs 1))
      (and p (save-excursion (goto-char (point-min)) (kill-line))))))

(defun c-transpose-paragraphs-up ()
  (interactive)
  (unless (or (minibufferp) (save-excursion (backward-paragraph) (bobp)))
    (let (p)
      (f-prepare-transpose)
      (backward-paragraph 2)
      (and (bobp) (setq p t) (newline))
      (forward-paragraph 2)
      (transpose-paragraphs -1)
      (and p (save-excursion (goto-char (point-min)) (kill-line))))))

(defun c-update-indent-offset-double ()
  (interactive)
  (f-update-indent-offset '(lambda (co) (* co 2))))

(defun c-update-indent-offset-half ()
  (interactive)
  (f-update-indent-offset '(lambda (co) (/ co 2))))

(defun c-word-capitalize ()
  (interactive)
  (if (use-region-p) (capitalize-region (region-beginning) (region-end))
    (capitalize-word -1)))

(defun c-word-downcase ()
  (interactive)
  (if (use-region-p) (downcase-region (region-beginning) (region-end))
    (downcase-word -1)))

(defun c-word-upcase ()
  (interactive)
  (if (use-region-p) (upcase-region (region-beginning) (region-end))
    (upcase-word -1)))

(defun f-beginning-of-line (&optional arg)
  (let (pt co)
    (save-excursion
      (f-skip-chars (line-beginning-position))
      (setq pt (point) co (current-column)))
    (cond ((eq arg 0) pt)
	  ((eq arg 1) co)
	  (t (move-to-column co)))))

(defun f-delete-trailing-whitespace ()
  (save-excursion
    (goto-char (point-max))
    (or buffer-read-only (bolp) (newline)))
  (delete-trailing-whitespace))

(defun f-each (ls &optional repeat)
  (let ((index (/ (cl-incf count 0) (or repeat 1))))
    (if (< index (length ls)) (elt ls index)
      (C-g))))

(defun f-incf (&optional first incr repeat)
  (let ((index (/ (cl-incf count 0) (or repeat 1))))
    (+ (or first 1) (* (or incr 1) index))))

(defun f-paragraph-set ()
  (setq paragraph-start "\f\\|[ \t]*$"
	paragraph-separate "[ \t\f]*$"))

(defun f-prepare-transpose ()
  (setq this-command 'transpose)
  (or (eq last-command this-command) (f-delete-trailing-whitespace)))

(defun f-query-replace-region (beg end)
  (let* ((txt (buffer-substring-no-properties beg end))
         (replacement (read-string "Replacement: " txt)))
    (goto-char beg)
    (setq mark-active nil)
    (query-replace txt replacement)
    (setq query-replace-defaults `(,(cons txt replacement)))))

(defun f-skip-chars (&optional start)
  (and start (goto-char start))
  (skip-chars-forward (concat " \t" skip-chars-regexp)))
(defvar-local skip-chars-regexp nil)

(defun f-switch-to-buffer (dir)
  (unless (minibufferp)
    (let ((bn (buffer-name))
	  (func (if (> dir 0) 'switch-to-next-buffer 'switch-to-prev-buffer))
	  p)
      (funcall func)
      (while (not (or buffer-file-name (not buffer-read-only) p))
	(or (get-buffer-process (current-buffer)) (kill-buffer))
        (funcall func)
	(and (string= bn (buffer-name)) (setq p t))))))

(defun f-update-indent-offset (func)
  (let ((pair (assoc major-mode '((python-mode python-indent-offset))))
        co offset)
    (unless pair (user-error "Major mode incorrect"))
    (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (skip-chars-forward " \n")
          (setq co (current-column))
          (and (> co 0) (or (not offset) (< co offset)) (setq offset co))
          (delete-char (- co))
          (insert (make-string (funcall func co) ? ))
          (forward-line)))
      (set (cadr pair) (funcall func offset))))

(defun last-edit-position-echo ()
  (interactive)
  (unless (minibufferp)
    (let ((pt last-edit-position))
      (when pt (goto-char pt)))))

(defun last-edit-position-update (beg end else)
  (unless (minibufferp)
    (setq last-edit-position (point))))
(defvar-local last-edit-position nil)
(add-hook 'after-change-functions 'last-edit-position-update)
