#|
  This file is a part of quicklisp-project-submission project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage quicklisp-project-submission
  (:nicknames :qps)
  (:use :cl :cl-github :cl-dot :trivia :alexandria)
  (:export
   #:submit))
(in-package :quicklisp-project-submission)

;; blah blah blah.


(defvar *default-remote* "origin")
(defvar *quicklisp-project-repo* "quicklisp-dummy/quicklisp-projects")
(defvar +faq+ "http://blog.quicklisp.org/2015/01/getting-library-into-quicklisp.html")
(defvar *name*)
(defvar *url*)
(defvar *system*)

(defun trim (string)
  (string-trim '(#\Space #\Newline #\Linefeed #\Return) string))
(defun tread-line (&optional (default ""))
  (let ((read (trim (read-line *query-io*))))
    (if (zerop (length read)) default read)))

(defun submit (&optional
                 pathname
                 &aux
                 (*default-pathname-defaults*
                  (or pathname *default-pathname-defaults*)))
  (let* ((*name* (ensure-repo))
         (*system* (check-repo))
         (*username* (username))
         ;; TODO: use oauth2
         (*password* (password))
         (*url* (format nil "https://github.com/~a/~a.git" *username* *name*)))
    (ensure-github-repo)
    (ensure-remote)
    (submit-issue)))

(defun username ()
  (format *query-io* "~&Your github name (set locally): ~@[~a~]" *username*)
  (or *username*
      (princ (tread-line))))

(defun password ()
  (format *query-io* "~&We need your github login password.
This is not stored in the disk, but watch your back, since there is no ****fication on REPL!
Password: ")
  (tread-line))

(defun ensure-repo ()
  (tagbody
    :start
    (restart-case
        (handler-case
            (uiop:run-program "git status"
                              :output *standard-output*
                              :error-output *error-output*)
          (error ()
            (error "Current directory ~a is not within any repository!"
                   *default-pathname-defaults*)))
      (git-init-here ()
        :report "initialize git repo in the current directory / add files"
        (uiop:run-program "git init" :output *standard-output* :error-output *error-output*)
        (uiop:run-program "bash -c 'git add *'" :output *standard-output* :error-output *error-output*)
        (uiop:run-program "git commit -m \"Initial commit by quicklisp-project-submission\"" :output *standard-output* :error-output *error-output*)
        (go :start))))
  (let ((root (trim (uiop:run-program "git rev-parse --show-toplevel" :output :string))))
    (format *query-io* "~&Repo root: ~a" root)
    (let ((name (pathname-name root)))
      (format *query-io* "~&Repo name identified as: ~a" name)
      name)))

(defun check-repo ()
  (tagbody
    :start
    (return-from check-repo
      (restart-case
          (let ((system
                 (handler-case (asdf:find-system *name*)
                   (error ()
                     (error "Failed to find asdf definition of ~a -- differs from your project name!"
                            *name*)))))
            (assert (asdf:system-description system) nil
                    "Your system lacks a system description. ~%See ~a"
                    +faq+)
            (assert (> 10 (length (asdf:system-description system))) nil
                    "Sorry, please provide a little more descriptive information...")
            (assert (asdf:system-license system) nil
                    "Your system lacks the license. ~%See ~a"
                    +faq+)
            (assert (asdf:system-author system) nil
                    "Your system lacks the author information. ~%See ~a"
                    +faq+)
            system)
        (retry ()
          (go :start))))))


(defun ensure-github-repo ()
  (handler-case
      (match (api-command (format nil "/repos/~a/~a" *username* *name*))
        ((plist :html-url url)
         (format *query-io* "~&Identified your Github repository at ~a" url)))
    (error ()
      (restart-case
          (error "Github Repo ~a/~a does not exists!" *username* *name*)
        (create-repo ()
          :report "Create this repository on github."
          (create-repository :name *name* :has-issues t)
          (format *query-io* "~&Repository successfully created!"))))))

(defun ensure-remote (&optional remote)
  (unless remote
    (handler-case
        (setf remote (trim (uiop:run-program "git remote show"
                                             :output :string
                                             :error-output *error-output*)))
      (UIOP/RUN-PROGRAM:SUBPROCESS-ERROR (c)
        (match c
          ((UIOP/RUN-PROGRAM:SUBPROCESS-ERROR :code 128)
           (restart-case
               (error "~&The remote of this repository is not set!")
             (set-remote ()
               (format *query-io* "~&Remote (default: origin, hit Enter): ")
               (let ((remote (tread-line "origin")))
                 (format *query-io* "~&Setting ~a as ~a" *url* remote)
                 (uiop:run-program (format nil "git remote add ~a ~a; git push --all ~a"
                                           remote *url* remote)
                                   :output *standard-output*
                                   :error-output *error-output*))))))))))

(defun submit-issue ()
  ;; POST /repos/:owner/:repo/issues
  (api-command (format nil "/repos/~a/issues" *quicklisp-project-repo*)
               :method :post
               :body
               (list :title (format nil "Please add ~a" *name*)
                     :body (format nil "
Please add ~a , available at ~a.

Description: ~a

License: ~a

Submitted using quicklisp-project-submission.

Real human comments: /~a/ "
                                   *name* *url*
                                   (asdf:system-description *system*)
                                   (asdf:system-license *system*)
                                   (progn
                                     (format *query-io* "~&Add 1-line human comment for Zach! (End with entering Ctrl-D)~%")
                                     (read-line))))))
