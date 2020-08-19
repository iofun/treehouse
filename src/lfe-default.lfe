(defun start (x y s)
  (user_default:start x y s))

(defun start-run (tick)
  (user_default:start_run tick))

(defun stop-run ()
  (user_default:stop_run))

(defun set-ships (ship sis)
  (user_default:set_ships ship sis))

(defun set-ships (ship from to)
  (set-ships ship (lists:seq from to)))

(defun set-ships (ship from to incr)
  (set-ships ship (lists:seq from to incr)))
