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

(DEFUN C:SERPATH ( / SPLIST)
	(SETQ SPLIST (GETENV "ACAD"))
	(WHILE x SPLIST
		(PRINT x)
	)
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (vlax-get-property (VLAX-ENAME->VLA-OBJECT OBJ) "AcDbDynBlockPropertyPanel Length"))
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (vlax-get-property (VLAX-ENAME->VLA-OBJECT OBJ) "property double Tw"))
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (getpropertyvalue OBJ "User Attribute 04"))
	(PRINT (vlax-property-available-p (VLAX-ENAME->VLA-OBJECT OBJ) "User Attribute 04"))
	(vlax-put-property (VLAX-ENAME->VLA-OBJECT OBJ) "User Attribute 04" "hello")
	(PRINT (getpropertyvalue OBJ "User Attribute 04"))
)

(DEFUN C:TEST ( / OBJ )
	(SETQ OBJ (car (entsel)))
	(PRINT (vla-get-ObjectName (VLAX-ENAME->VLA-OBJECT OBJ)))
)
info

(entmake ((0 . "LINE") (10 0.0) (20 0.0) (11 0.0) (21 2.717)))


vla-Import doc importFile insertPoint scalefactor