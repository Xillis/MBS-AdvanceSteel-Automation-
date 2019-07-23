(Defun c:SBS_CraneDataImport ( / EXCELFILE CELL CRANELIST CELLVALUE CRANEDATA CELLLIST OLDVAR EXCELBOOK EXCELAPPLICATION EXCELSHEET OLDERR BLOCKDATA ATTTEST)
	(vl-load-com)
	(print "SBS_CraneDataImport V1.0.0")
	;;Internal functun calls
	;;Error reset
	(defun *Error-Reset* (msg / )
		(princ "error: ")
		(princ msg)
		(princ)
		(vl-bt)
		(if (/= EXCELFILE nil)
			(progn
				(vl-catch-all-apply 'vlax-invoke-method (list EXCELBOOK "Close"))
				(vl-catch-all-apply 'vlax-invoke-method (list EXCELAPPLICATION "Quit"))
			)
		)
		(done_dialog)
		(~SVVCF OLDVAR)
		(setq *error* OLDERR)
		(vla-EndUndoMark 
			(vla-get-ActiveDocument 
				(vlax-get-acad-object)
			)
		)
		(princ)
	)
	;;Functoun to set system variables
	(defun ~SVVCF ( SYSVAR / SYSVAR OLDVAR)
		(foreach var SYSVAR
			(setq OLDVAR (append OLDVAR (list (list(nth 0 var) (getvar (nth 0 var))))))
			(setvar (nth 0 var) (nth 1 var))
		)
	OLDVAR
	)
	;;Open Excel File
	(defun ~Open_Excel_File ( )
		(setq EXCELFILE (findfile (getfiled "Select Crain Data Excel File" (strcat "G:/MBS/Order/" (substr (getvar "dwgname") 1 (vl-string-search "-"(getvar "dwgname")))"/" ) "xlsm" 0)))
		(if (/= EXCELFILE nil)
			(progn
				(setq EXCELAPPLICATION (vlax-get-or-create-object "Excel.Application"))
				(vla-put-visible EXCELAPPLICATION :vlax-true)
				(vlax-put-property EXCELAPPLICATION 'DisplayAlerts :vlax-false)
				(setq EXCELBOOK (vl-catch-all-apply 'vla-open (list (vlax-get-property EXCELAPPLICATION "WorkBooks") EXCELFILE)))
			)
			(prompt (strcat "\nFile Not Found: " (car EXCELFILE)))
		)
	)
	;;Get Excel File info
	(defun ~Get_Excel_Data ( EXCELDATA / EXCELDATA )
		(if (/= EXCELFILE nil)
			(progn
				(setq 
					EXCELDATA
						(cons (car EXCELDATA)
							(list (mapcar '(lambda (i)
								(setq EXCELSHEET (vl-catch-all-apply 'vlax-get-property (list (vlax-get-property EXCELBOOK "Sheets") "Item" (Car i))))
								(if (not (vl-catch-all-error-p EXCELSHEET))
									(progn
										(vlax-invoke-method EXCELSHEET "Activate")
										(cons (car i)
											(list (mapcar '(lambda (x)
												(cons x
													(vlax-variant-value
														(vlax-get-property
															(vlax-get-property
																(vlax-get-property EXCELSHEET 'Cells)
															"Range" x)
														'Value2)
													)
												)
											)
											(cadr i)))
										)
									)
									(prompt (strcat "\nExcel Sheet Not Found: " (car i)))
								)
							)
							(cadr EXCELDATA)))
						)
				)
			)
			(prompt (strcat "\nFile Not Found: " (car EXCELDATA))) 
		)
	)
	;;Close Excel File
	(defun ~Close_Excel_File ( )
		(vl-catch-all-apply 'vlax-invoke-method (list EXCELBOOK "Close"))
		(vl-catch-all-apply 'vlax-invoke-method (list EXCELAPPLICATION "Quit"))
		(vlax-release-object EXCELBOOK)
		(vlax-release-object EXCELAPPLICATION)
		(vlax-release-object EXCELSHEET)
	)
	;;Populate a Dialog list from a list
	(defun ~Populate_List ( DIAKEY DIALIST / DIAKEY DIALIST )
		(start_list DIAKEY)
			(mapcar 'add_list DIALIST)
		(end_list)
	)
	;;Get a list from a table
	(defun ~Make-List ( TABLE / CLIST INFO POS RL TABLE)
		(SETQ 
			INFO (VL-GET-RESOURCE TABLE)
			POS 1
			RL " "
		)
		(WHILE (not (null RL))
			(SETQ RL (read (substr INFO POS )))
			(IF (not (null RL))
				(SETQ CLIST (APPEND (LIST RL) CLIST))
			)
			(SETQ POS (+ POS 2))
			(if (vl-string-position (ASCII "\n") (substr INFO POS))
				(SETQ POS (+ POS (VL-STRING-POSITION (ASCII "\n") (substr INFO POS))))
				(setq rl nil)
			)
		)
		(REVERSE CLIST)
	)
	;;searches a string for the first numeric character and returns a string containing the characters after the number starting with the number
	(defun ~StrChr ( STRING / POS STRING )
		(setq POS 1)
		(repeat (strlen STRING)
			(if (not (wcmatch (substr STRING POS 1) "#"))
				(setq POS (1+ POS))
			)
		)
		(substr string POS)
	)
	;;searches a string for the first numeric character and returns a string containing the characters befor the number
	(defun ~StrChrfr ( STRING / POS STRING )
		(setq POS 1)
		(repeat (strlen STRING)
			(if (not (wcmatch (substr STRING POS 1) "#"))
				(setq POS (1+ POS))
			)
		)
		(substr string 1 (1- POS))
	)
	;;sets the item lines to metric or imperial
	(defun ~Set-Description-Unit ()
		(if (= (getvar "Lunits") 2)
			(progn
				(set_tile "CraneCapacityT" "Crane Capacity (tonne): ")
				(set_tile "BridgeWeightT" "Bridge Weight:(Kg) ")
				(set_tile "TrolleyWeightT" "Trolley Weight:(Kg) ")
				(set_tile "WheelLoadT" "Wheel Load:(Kn) ")
				(set_tile "SideThrustT" "Side Thrust:(Kn) ")
				(set_tile "TractiveForceT" "Tractive Force:(Kn/side) ")
			)
			(progn
				(set_tile "CraneCapacityT" "Crane Capacity:(ton) ")
				(set_tile "BridgeWeightT" "Bridge Weight:(lbs) ")
				(set_tile "TrolleyWeightT" "Trolley Weight:(lbs) ")
				(set_tile "WheelLoadT" "Wheel Load:(kips) ")
				(set_tile "SideThrustT" "Side Thrust:(kips) ")
				(set_tile "TractiveForceT" "Tractive Force:(kips/side) ")
			)
		)
	)
	;;sets the crane info in the Dialog box
	(defun ~Set-Dia-Crane-Info ( / CRANENUMBER )
		(if (= (get_tile "CraneNumber") "")
				(setq CRANENUMBER "0")
				(setq CRANENUMBER (get_tile "CraneNumber"))
		)
		(setq BLOCKDATA (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA))))))
		(foreach a BLOCKDATA
			(cond
				((null (cadr a)) (setq BLOCKDATA (subst (list (car a) "n/a") a BLOCKDATA)))
				((and (or (= (car a) "Crane Span") (= (~StrChrfr (car a)) "Wheel base")) (= (getvar "Lunits") 4)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (cadr a) "feet" "inch"))) a BLOCKDATA)))
				((and (or (= (car a) "Crane Span") (= (~StrChrfr (car a)) "Wheel base")) (= (getvar "Lunits") 2)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (cadr a) "feet" "millimeter")2 0))a BLOCKDATA)))
				((or (= (car a) "Number of Cranes") (= (~StrChrfr (car a)) "Number of Wheels")) (setq BLOCKDATA (subst (list (car a) (rtos (cadr a)2 0)) a BLOCKDATA)))
				((and (= (car a) "Crane Seperation") (= (getvar "Lunits") 4)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (cadr a) "feet" "inch"))) a BLOCKDATA)))
				((and (= (car a) "Crane Seperation") (= (getvar "Lunits") 2)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (cadr a) "feet" "millimeter")2 0)) a BLOCKDATA)))
				((and (= (~StrChrfr (car a)) "Crane Capacity") (= (getvar "Lunits") 4))   (setq BLOCKDATA (subst (list (car a) (rtos (cadr a)2 0)) a BLOCKDATA)))
				((and (= (~StrChrfr (car a)) "Crane Capacity") (= (getvar "Lunits") 2)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (cadr a) "ton" "tonne")2 2)) a BLOCKDATA)))
				((and (or (= (~StrChrfr (car a)) "Bridge Weight") (= (~StrChrfr (car a)) "Trolley Weight")) (= (getvar "Lunits") 4)) (setq BLOCKDATA (subst (list (car a) (rtos (* (cadr a) 1000) 2 0)) a BLOCKDATA)))
				((and (or (= (~StrChrfr (car a)) "Bridge Weight") (= (~StrChrfr (car a)) "Trolley Weight")) (= (getvar "Lunits") 2)) (setq BLOCKDATA (subst (list (car a) (rtos (cvunit (* (cadr a) 1000) "pound" "kilogram") 2 0)) a BLOCKDATA)))
				((and (or (= (~StrChrfr (car a)) "Wheel Load") (= (car a) "Side Thrust") (= (car a) "Tractive Force")) (= (getvar "Lunits") 4)) (setq BLOCKDATA (subst (list (car a) (rtos (cadr a) 2 2)) a BLOCKDATA)))
				((and (or (= (~StrChrfr (car a)) "Wheel Load") (= (car a) "Side Thrust") (= (car a) "Tractive Force")) (= (getvar "Lunits") 2)) (setq BLOCKDATA (subst (list (car a) (rtos (* (cadr a) 4.4482216) 2 2)) a BLOCKDATA)))
				((= (type (cadr a)) 'REAL) (setq BLOCKDATA (subst (list (car a) (rtos (cadr a) 2 2)) a BLOCKDATA)))
				((= (type (cadr a)) 'INT) (seq BLOCKDATA (subst (list (car a) (itoa (cadr a))) a BLOCKDATA)))
				(t)
			)
		)
		(foreach a BLOCKDATA
			(cond
				((= (~strchr (car a)) (itoa (1+ (atoi CRANENUMBER))) "2") (set_tile (~StrChrfr (car a)) (cadr a)))
				((= (~strchr (car a)) (itoa (1+ (atoi CRANENUMBER))) "1") (set_tile (~StrChrfr (car a)) (cadr a)))
				(t (set_tile (car a) (cadr a)))
			)
		)
	)
	;;Gets Crane Info From Excel File
	(defun ~Get-Crane-Info (  )
		(setq
			CELLLIST 'nil
			CRANEDATA 'nil
		)
		(foreach i (~Make-List "Project Data Info Map")
			(If (and (/= (cadr i) "n/a") (/= (cadr i) "L/400"))
				(setq CELLLIST
					(append
						(list (append
							(list (car i))
							(list 
								(strcat
									(cadr i)
									(~StrChr (car (nth (atoi $value) CRANELIST)))
								)
							)
						))
					CELLLIST)
				)
			)
		)
		(setq CRANEDATA 
			(~Get_Excel_Data
				(append
					(list EXCELFILE)
					(list 
						(append
							(list (cons '"Project Data"
								(list (mapcar '(lambda (z) (cadr z)) CELLLIST)
								)
							))
						)
					)
				)
			)
		)
		(set_tile "CraneNumber" "0")
		(~Set-Dia-Crane-Info)
		(if (= (get_tile "Number of Cranes") "2")
			(progn
				(start_list "CraneNumber")
					(add_list "1")
					(add_list "2")
				(end_list)
			)
			(progn
				(start_list "CraneNumber")
					(add_list "1")
				(end_list)
			)
		)
		(set_tile "CraneNumber" "0")
	)
	;;Crane Start Dialog function
	(defun ~Start-DIA ( / DIA-ID )
		(setq DIA-ID (load_dialog "SBS Crane Selection.DCL"))
			(if (not (new_dialog "SBS_CRANE_SELECTION" DIA-ID))
				(exit)
			)
			(if (= (getvar "Lunits") 2)
				(mode_tile "Metric" 1)
				(progn
					(setvar "LUNITS" 4)
					(mode_tile "Imp" 1)
				)
			)
			(~Set-Description-Unit)
			(set_tile "Crane System" (~Check_block_insert 1))
			(~Populate_List "Crane" 
				(mapcar 
					'(lambda (x)
						(cdr x)
					)
					CRANELIST
				)
			)
			(action_tile "Metric"
				(strcat
					"(mode_tile \"Metric\" 1)"
					"(mode_tile \"Imp\" 0)"
					"(setvar \"Lunits\" 2)"
					"(~Set-Description-Unit)"
					"(~Set-Dia-Crane-Info)"
				)
			)
			(action_tile "Imp"
				(strcat
					"(mode_tile \"Metric\" 0)"
					"(mode_tile \"Imp\" 1)"
					"(setvar \"Lunits\" 4)"
					"(~Set-Description-Unit)"
					"(~Set-Dia-Crane-Info)"
				)
			)
			;;(action_tile "Crane System" 
			;;;	(if (not (= (~Check_block_insert (atoi $value)) $value))
			;;"(print (~Check_block_insert (atoi $value)))"
			;;		(progn
			;;		(print $value)
			;;		"(set_tile \"error\" (strcat \"Crane System \" $value \" is already in use\"))"
			;;			(set_tile \"Crane System\" (~Check_block_insert 1))
			;;		)
			;;		(print $value)
			;;	)
			;;)
			(action_tile "CraneNumber" "(~Set-Dia-Crane-Info)")
			(action_tile "Crane"  "(~Get-Crane-Info)")
			(action_tile "accept" 
				"(if (= (get_tile \"Crane\") \"\")
					(set_tile \"error\" \"Please Select a Crane From the List\")
					(if (not (= (~Check_block_insert (atoi (get_tile \"Crane System\"))) (get_tile \"Crane System\")))
						(progn 
							(set_tile \"error\" (strcat \"Crane System \" (get_tile \"Crane System\") \" is already in use\"))
							(set_tile \"Crane System\" (~Check_block_insert 1))
						)
						(progn
							(setq BLOCKDATA (append (list (cons '\"Crane System\" (list (get_tile \"Crane System\")))) BLOCKDATA))
							(done_dialog)
						)
						)
					)
				)"
			)
			(action_tile "cancle" (strcat "(done_dialog)" "(exit)"))
		(start_dialog)
		(unload_dialog DIA-ID)
	)
	;;Checks for and isolates inserted blocks of a specified name
	(defun ~Check_block_insert ( COUNT / OBJSS OBJ INDEX COUNT SLIST)
	
		(setq
			OBJSS (ssget "_A" '((0 . "INSERT")))
			INDEX 0
		)
		(if (not (null OBJSS))
			(progn
				(while (/= NIL (setq OBJ (ssname OBJSS INDEX)))
					(if 
						(= 
							(vlax-get-property (VLAX-ENAME->VLA-OBJECT  obj)
								(if (vlax-property-available-p (VLAX-ENAME->VLA-OBJECT obj) 'effectivename)
									'effectivename
									'name
								)
							)
							"CRANE INFO"		
						)
					(setq SLIST (append (list (atoi (~StrChr (getpropertyvalue OBJ "CRANE_SYSTEM" )))) SLIST))
					)
					(setq INDEX (1+ INDEX))
				)
				(setq SLIST (vl-sort SLIST '<))
				(foreach i SLIST
					(if (= i COUNT)
						(setq COUNT (1+ COUNT))
					)
				)
			)
		)
		(itoa COUNT)
	)
	;;inserts the crane data block
	(defun ~insert_crane_data_table ( / WB1 WB2 )
		(command "_.-insert" "CRANE INFO" pause "" "" "")
		(foreach x BLOCKDATA
			(setq ATTTEST (entlast))
			(while (setq ATTTEST (entnext ATTTEST))
				(if (= (cdr (assoc 2 (entget ATTTEST))) (strcase (vl-string-translate " " "_" (car x))))
					(cond
						((= (car x) "Control")
							(setpropertyvalue (entlast) (strcase (vl-string-translate " " "_" (car x))) (vl-string-right-trim "CONTROLLLED" (strcase(cadr x))))
							(setpropertyvalue (entlast) (strcat (strcase (vl-string-translate " " "_" (car x))) "2") (vl-string-right-trim "CONTROLLLED" (strcase(cadr x))))
						)
						((or (= (car x) "Control") (= (car x) "Crane Classification") (= (car x) "Side Thrust") (= (car x) "Tractive Force"))
							(setpropertyvalue (entlast) (strcase (vl-string-translate " " "_" (car x))) (strcase(cadr x)))
							(setpropertyvalue (entlast) (strcat (strcase (vl-string-translate " " "_" (car x))) "2") (strcase(cadr x)))
						)
						((= (car x) "Crane System")
							(setpropertyvalue (entlast) (strcase (vl-string-translate " " "_" (car x))) (strcat "%%uCRANE SYSTEM #" (cadr x)))
						)
						(t (setpropertyvalue (entlast) (strcase (vl-string-translate " " "_" (car x))) (strcase(cadr x))))
					)
				)
			)
		)
		(foreach i (~Make-List "Project Data Info Map")
			(if (not (assoc (car i) BLOCKDATA))
				(setpropertyvalue (entlast) (strcase (vl-string-translate " " "_" (car i))) (cadr i))
			)
		)
		(cond
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "1") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "4"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 0)
			)
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "1") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "8"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 1)
				(setpropertyvalue (entlast) "WHEEL_BASE11" (cadr (assoc "Wheel base12" BLOCKDATA)))
				(setq
					WB1 (cadr (assoc "Wheel base11" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
					WB2 (cadr (assoc "Wheel base12" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
				)
				(if (= (getvar "Lunits") 4)
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "inch")))
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "millimeter")))
				)
			)
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "2") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "4") (= (cadr (assoc "Number of Wheels2" BLOCKDATA)) "4"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 0)
				(setpropertyvalue (entlast) "CRANE_SEPERATIONS" (cadr (assoc "Crane Seperation" BLOCKDATA)))
				(foreach v BLOCKDATA
					(if (and (wcmatch (car v) "*#") (wcmatch (car v) "~*##"))	
						(if (not (= (cadr v) (cadr (assoc (strcat (~StrChrfr (car v)) "2") BLOCKDATA))))
							(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 2)
						)
					)
				)
			)
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "2") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "4") (= (cadr (assoc "Number of Wheels2" BLOCKDATA)) "8"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 3)
				(setpropertyvalue (entlast) "CRANE_SEPERATIONS" (cadr (assoc "Crane Seperation" BLOCKDATA)))
				(setpropertyvalue (entlast) "WHEEL_BASE21" (cadr (assoc "Wheel base22" BLOCKDATA)))
				(setq
					WB1 (cadr (assoc "Wheel base21" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
					WB2 (cadr (assoc "Wheel base22" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
				)
				(if (= (getvar "Lunits") 4)	
						(setpropertyvalue (entlast) "WHEEL_BASE2S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "inch")))
						(setpropertyvalue (entlast) "WHEEL_BASE2S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "millimeter")))
				)
			)
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "2") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "8") (= (cadr (assoc "Number of Wheels2" BLOCKDATA)) "4"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 4)
				(setpropertyvalue (entlast) "CRANE_SEPERATIONS" (cadr (assoc "Crane Seperation" BLOCKDATA)))
				(setpropertyvalue (entlast) "WHEEL_BASE11" (cadr (assoc "Wheel base12" BLOCKDATA)))
				(setq
							WB1 (cadr (assoc "Wheel base11" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
							WB2 (cadr (assoc "Wheel base12" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
				)
				(if (= (getvar "Lunits") 4)
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "inch")))
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- WB1 (* 	WB2 2)) "feet" "millimeter")))
				)
			)
			((and (= (cadr (assoc "Number of Cranes" BLOCKDATA)) "2") (= (cadr (assoc "Number of Wheels1" BLOCKDATA)) "8") (= (cadr (assoc "Number of Wheels2" BLOCKDATA)) "8"))
				(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 1)
				(setpropertyvalue (entlast) "CRANE_SEPERATIONS" (cadr (assoc "Crane Seperation" BLOCKDATA)))
				(setpropertyvalue (entlast) "WHEEL_BASE11" (cadr (assoc "Wheel base12" BLOCKDATA)))
				(setpropertyvalue (entlast) "WHEEL_BASE21" (cadr (assoc "Wheel base22" BLOCKDATA)))
				(foreach v BLOCKDATA
					(if (and (wcmatch (car v) "*#") (wcmatch (car v) "~*##"))	
						(if (not (= (cadr v) (cadr (assoc (strcat (~StrChrfr (car v)) "2") BLOCKDATA))))
							(setpropertyvalue (entlast) "AcDbDynBlockPropertyBlock Table1" 5)
							
						)
					)
				)
				(setq
					WB1 (cadr (assoc "Wheel base11" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
					WB2 (cadr (assoc "Wheel base12" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
				)
				(if (= (getvar "Lunits") 4)
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- (* 	WB2 2) WB1) "feet" "inch")))
					(setpropertyvalue (entlast) "WHEEL_BASE1S" (rtos (cvunit (- (* 	WB2 2) WB1) "feet" "millimeter")))
				)
				(setq
					WB1 (cadr (assoc "Wheel base21" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
					WB2 (cadr (assoc "Wheel base22" (mapcar 'list (mapcar '(lambda (o) (car o)) CELLLIST) (mapcar '(lambda (p) (cdr p)) (cadr (car (cadr CRANEDATA)))))))
				)
				(if (= (getvar "Lunits") 4)
					(setpropertyvalue (entlast) "WHEEL_BASE2S" (rtos (cvunit (- (* 	WB2 2) WB1) "feet" "inch")))
					(setpropertyvalue (entlast) "WHEEL_BASE2S" (rtos (cvunit (- (* 	WB2 2) WB1) "feet" "millimeter")))
				)
			)
		)
	)
	(defun ~Unit_Set ( )
		(if (= (getvar "Lunits") 4)
			(progn
				(setpropertyvalue (entlast) "CCUNIT1" "(ton)")
				(setpropertyvalue (entlast) "CCUNIT2" "(ton)")
				(setpropertyvalue (entlast) "BWUNIT1" "(lbs)")
				(setpropertyvalue (entlast) "BWUNIT2" "(lbs)")
				(setpropertyvalue (entlast) "TWUNIT1" "(lbs)")
				(setpropertyvalue (entlast) "TWUNIT2" "(lbs)")
				(setpropertyvalue (entlast) "WLUNIT1" "(kips)")
				(setpropertyvalue (entlast) "WLUNIT2" "(kips)")
				(setpropertyvalue (entlast) "STUNIT1" "(kips)")
				(setpropertyvalue (entlast) "STUNIT2" "(kips)")
				(setpropertyvalue (entlast) "TFUNIT1" "(kips/Side)")
				(setpropertyvalue (entlast) "TFUNIT2" "(kips/Side)")
			)
			(progn
				(setpropertyvalue (entlast) "CCUNIT1" "(tonne)")
				(setpropertyvalue (entlast) "CCUNIT2" "(tonne)")
				(setpropertyvalue (entlast) "BWUNIT1" "(Kg)")
				(setpropertyvalue (entlast) "BWUNIT2" "(Kg)")
				(setpropertyvalue (entlast) "TWUNIT1" "(Kg)")
				(setpropertyvalue (entlast) "TWUNIT2" "(Kg)")
				(setpropertyvalue (entlast) "WLUNIT1" "(Kn)")
				(setpropertyvalue (entlast) "WLUNIT2" "(Kn)")
				(setpropertyvalue (entlast) "STUNIT1" "(Kn)")
				(setpropertyvalue (entlast) "STUNIT2" "(Kn)")
				(setpropertyvalue (entlast) "TFUNIT1" "(Kn/Side)")
				(setpropertyvalue (entlast) "TFUNIT2" "(Kn/Side)")
			)
		)
	)
	;;End of internal function calls
	;;Main function
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq
		OLDERR *error*
		*error* *Error-Reset*
		OLDVAR (~SVVCF (list '("CMDECHO" 0) '("LUNITS" 2)))
		CELL (list '"B3")
		CELLVALUE  "TEMP"
	)
	(~Open_Excel_File)
	(while 	(not (null  CELLVALUE))
		(setq
			CELLVALUE (car (cadr (car (cadr 
				(~Get_Excel_Data
					(append
						(list EXCELFILE)
						(list 
							(append
								(list (cons '"Project Data" (list CELL)))
							)
						)
					)
				)
			))))
			CELL (list (strcat "B" (itoa (1+ (atoi (substr (car CELL) 2))))))
		)
		(if (not (null (cdr CELLVALUE)))
			(setq CRANELIST (append (LIST CELLVALUE) CRANELIST))
		)
		(setq CELLVALUE (cdr CELLVALUE))
	)
	(if (not (null CRANELIST))
		(progn
			(setq CRANELIST (reverse CRANELIST))		
			(~start-DIA)
		)
	)
	(~Close_Excel_File)
	(~insert_crane_data_table)
	(~Unit_Set)
	(~SVVCF OLDVAR)
	(setq *error* OLDERR)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(princ)
)
