(declaim (optimize (speed 3) (debug 0) (safety 0)))

(defconstant +n+ 10000000)

(let* ((h (make-array +n+ :element-type '(unsigned-byte 32))))
  (declare (type (simple-array (unsigned-byte 32)) h))

  (defun push-down (pos n)
    (declare (type (unsigned-byte 32) pos n)
             (inline push-down)
             (optimize (speed 3) (debug 0) (safety 0)))
    (loop for j of-type (unsigned-byte 32) = (1+ (* 2 pos))
          while (< j n)
          do (when (and (< (1+ j) n)
                        (> (aref h (1+ j))
                           (aref h j)))
               (incf j))
             (when (>= (aref h pos)
                       (aref h j))
               (return))
             (rotatef (aref h pos)
                      (aref h j))
             (setf pos j)))

  (defun main ()
    (declare (inline main))
    (dotimes (i +n+)
      (setf (aref h i) i))
    (loop for i from (floor +n+ 2) downto 0
          do (push-down i +n+))
    (let ((n +n+))
      (loop while (> n 1)
            do (rotatef (aref h 0)
                        (aref h (1- n)))
               (decf n)
               (push-down 0 n)))
    (dotimes (i +n+)
      (assert (= (aref h i) i)))
    (format t "Done in ~a ms~%"
            (floor (* 1000 (get-internal-run-time))
                   internal-time-units-per-second)))

  (main))
