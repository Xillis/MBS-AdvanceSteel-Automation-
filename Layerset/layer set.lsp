(defun C:SBS-LAYERSET (/ TDATA LDATA RL OLDVAR MODELS INDEX SORTLIST OBJ TOTAL)
	(print "SBS-LAYERSET V1.0.4")
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq OLDVAR (CWL-SVVCF (list '("CMDECHO" 0) '("CLAYER" "0"))))
	(if (not (findfile "Layer data.sbs"))
		(setq TDATA (open "X:/Autocad/Lisp Routines/Layer data.sbs" "r"))
		(setq TDATA (open (findfile "Layer data.sbs") "r"))
	)
	(setq RL (read-line tdata))
	(while (not (null RL))
		(setq RL (read RL))
		(command "-LAYER" "M" (car RL) "C" (cadr RL) (car RL) "L" (caddr RL) (car RL) "")
		(setq LDATA (append (list RL) LDATA))
		(setq RL (read-line tdata))
	)
	(setq LDATA (reverse LDATA)
		TOTAL 0)
	(close TDATA)
	(setq SORTLIST '((0 . "ASTPLATE")(0 . "ASTBEAM")(0 . "ASTXWORKINGPLANE")(0 . "ASTXMODELVIEW")(0 . "ASTGRID")(0 . "ASTSPECIALPART")(0 . "ASTXPLATEFOLDRELATION") (0 . "ASTXCAMERA") (0 . "ASTXUSERDEFINEDPOINT") (0 . "ASTWELD")))
	(foreach x SORTLIST
		(if (setq MODELS (ssget "_A" (list x)))
			(setq TOTAL (+ TOTAL (sslength MODELS)))
		)
	)
	(acet-ui-progress "Setting Layers:" TOTAL)
	(setq TOTAL 0)
	(foreach x SORTLIST 
		(if (setq MODELS(ssget "_A" (list x)))
			(progn
				(setq INDEX 0)
				(while (/= NIL(setq OBJ (ssname MODELS INDEX)))
					(if (/= (cdr (assoc '70 (tblsearch "LAYER" (cdr (assoc '8 (entget OBJ)))))) 4)					
						(foreach y LDATA
							(if (nth 3 y)
								(foreach z (nth 3 y)
									(cond
										((= (cdr (assoc '8 (entget OBJ))) (car y)))
										((and (/= (car z) "ObjectName") (OR (= x (car SORTLIST)) (= x (cadr SORTLIST)) (= x (nth 5 SORTLIST))))
											(if (= (getpropertyvalue OBJ (car z)) (cadr z))
												(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer (car y))
											)
										)
										((and (= (car z) "ObjectName") (or (= x (caddr SORTLIST)) (= x (cadddr SORTLIST)) (= x (nth 4 SORTLIST)) (= x (nth 6 SORTLIST)) (= x (nth 7 SORTLIST)) (= x (nth 8 SORTLIST)) (= x (nth 9 SORTLIST))))
											(if (= (vlax-get-property (vlax-ename->vla-object OBJ) (car z)) (cadr z))
												(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer (car y))
											)
										)
									)
								)
							)
						)
					)
					(setq INDEX (1+ INDEX))
					(setq TOTAL (1+ TOTAL))
					(acet-ui-progress TOTAL)
				)
			)
		)
	)
	(CWL-SVVCF OLDVAR)
	(print "Layers have been set")
	(acet-ui-progress)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(prin1)
)

(defun CWL-SVVCF ( sysvar / sysvar oldvar)
	;;(print "start CWL-SVVCF")
	(foreach var sysvar
		(setq oldvar (append oldvar (list (list(nth 0 var) (getvar (nth 0 var))))))
		(setvar (nth 0 var) (nth 1 var))
	)
	;;(print "end CWL-SVVCF")
	oldvar
)