#|
  This file is a part of quicklisp-project-submission project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :quicklisp-project-submission.test
  (:use :cl
        :quicklisp-project-submission
        :fiveam
        :cl-github-v3 :cl-dot :trivia :alexandria))
(in-package :quicklisp-project-submission.test)



(def-suite :quicklisp-project-submission)
(in-suite :quicklisp-project-submission)

;; run test with (run! test-name) 

(test quicklisp-project-submission

  )



