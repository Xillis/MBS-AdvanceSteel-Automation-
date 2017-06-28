(DEFUN C:SBS-LAYERSET (/ TDATA LDATA RL oldvar MODELS INDEX SORTLIST OBJ)
	(PRINT "SBS-LAYERSET V1.0.1")
	(setq oldvar (CWL-SVVCF (list '("CMDECHO" 0) '("CLAYER" "0"))))
	(IF (NOT (findfile "Layer data.sbs"))
		(SETQ TDATA (OPEN "X:/Autocad/Lisp Routines/Layer data.sbs" "r"))
		(SETQ TDATA (OPEN (FINDFILE "Layer data.sbs") "r"))
	)
	(setq RL (read-line tdata))
	(while (not (null RL))
		(SETQ RL (READ RL))
		(COMMAND "-LAYER" "M" (CAR RL) "C" (CADR RL) (CAR RL) "L" (CADDR RL) (CAR RL) "")
		(SETQ LDATA (APPEND (LIST RL) LDATA))
		(setq RL (read-line tdata))
	)
	(CLOSE TDATA)
	(SETQ SORTLIST '((0 . "ASTPLATE")(0 . "ASTBEAM")(0 . "ASTXWORKINGPLANE")(0 . "ASTXMODELVIEW")(0 . "ASTGRID")))
	(FOREACH x SORTLIST 
		(IF (SETQ MODELS(SSGET "_A" (LIST x)))
			(PROGN
				(SETQ INDEX 0)
				(WHILE (/= NIL(SETQ OBJ (SSNAME MODELS INDEX)))
					(FOREACH y LDATA
						(IF (NTH 3 y)
							(FOREACH z (NTH 3 y)
								(COND							
									((AND (/= (CAR z) "ObjectName") (OR (= x (CAR SORTLIST)) (= x (CADR SORTLIST))))
										(IF (= (getpropertyvalue OBJ (CAR z)) (CADR z))
											(VLAX-PUT-PROPERTY (VLAX-ENAME->VLA-OBJECT OBJ) 'Layer (CAR y))
										)
									)
									((AND (= (CAR z) "ObjectName") (OR (= x (CADDR SORTLIST)) (= x (CADDDR SORTLIST)) (= x (NTH 4 SORTLIST))))
										(IF (= (vlax-get-property (VLAX-ENAME->VLA-OBJECT OBJ) (CAR z)) (CADR z))
											(VLAX-PUT-PROPERTY (VLAX-ENAME->VLA-OBJECT OBJ) 'Layer (CAR y))
										)
									)
								)
							)
						)
					)
					(SETQ INDEX (1+ INDEX))
				)
			)
		)
	)
	(CWL-SVVCF oldvar)
	(PRINT "Layers have been set")
	(PRIN1)
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
