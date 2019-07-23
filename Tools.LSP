(DEFUN C:INFO ( / OBJ )
	(vl-load-com)
	(SETQ OBJ (car (entsel)))
	(PRINT "dxf OUTPUT")
	(foreach  p (ENTGET OBJ)
		(PRINT p)
	)
	(PRINT "Properties Dunp")
	(dumpallproperties OBJ 1)
	(PRINT "VLX Dump")
	(print (vlax-dump-object (VLAX-ENAME->VLA-OBJECT OBJ) T))
	(print "1")
	(vla-getxdata (VLAX-ENAME->VLA-OBJECT OBJ) "" 'xtypeOut 'xdataOut)
	(print xtypeOut)
	(print xdataOut)
	(print (VLAX-ENAME->VLA-OBJECT OBJ))
)

(defun c:dxfdump ( / OBJ )
(SETQ OBJ (car (entsel)))
	(PRINT "dxf OUTPUT")
	(foreach  p (ENTGET OBJ)
		(PRINT p)
	)
	(if (wcmatch (setq blk (cdr (assoc 2 (entget ent)))) "`**")
        (if
            (and
                (setq rep
                    (cdadr
                        (assoc -3
                            (entget
                                (cdr
                                    (assoc 330
                                        (entget
                                            (tblobjname "block" blk)
                                        )
                                    )
                                )
                               '("acdbblockrepbtag")
                            )
                        )
                    )
                )
                (setq rep (handent (cdr (assoc 1005 rep))))
            )
            (setq blk (cdr (assoc 2 (entget rep))))
        )
    )
	(print blk)
	)

(defun *error* (msg)
	(vl-bt)
	(princ "error: ")
	(princ msg)
	(princ)
)

(DEFUN C:SERPATH ( / SPLIST)
	(SETQ SPLIST (GETENV "ACAD"))
	(WHILE x SPLIST
		(PRINT x)
	)
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(print (ispropertyreadonly OBJ "AcDbDynBlockPropertyBlock Table1"))
	(setpropertyvalue OBJ "AcDbDynBlockPropertyBlock Table1" 3)
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (vlax-get-property (VLAX-ENAME->VLA-OBJECT OBJ) "property double Tw"))
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (getpropertyvalue OBJ "User Attribute 04"))
	(print (ispropertyreadonly OBJ "User Attribute 04"))
	(setpropertyvalue OBJ "User Attribute 04" "yay")
	(PRINT (getpropertyvalue OBJ "User Attribute 04"))
	(print (vlax-get-property (VLAX-ENAME->VLA-OBJECT OBJ) "User Attribute 04"))
	(PRINT (vlax-property-available-p (VLAX-ENAME->VLA-OBJECT OBJ) '"User Attribute 04"))
	(PRINT (vlax-property-available-p (VLAX-ENAME->VLA-OBJECT OBJ) '"User Attribute 04" t))
	(vlax-put-property (VLAX-ENAME->VLA-OBJECT OBJ) '"User Attribute 04" "hello")
	(PRINT (getpropertyvalue OBJ "User Attribute 04"))
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (vla-get-ObjectName (VLAX-ENAME->VLA-OBJECT OBJ)))
)
info

(entmake ((0 . "LINE") (10 0.0) (20 0.0) (11 0.0) (21 2.717)))

 
(strcat "AutoCAD.AcCmColor." (substr (getvar "ACADVER")1 2))

vla-Import doc importFile insertPoint scalefactor