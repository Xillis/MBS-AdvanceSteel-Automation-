(defun ~Get_Excel_Data ( EXCELDATA / FILE EXCELFILE EXCELBOOK EXCELDATA EXCELAPPLICATION EXCELSHEET )
	(setq EXCELFILE (findfile (car EXCELDATA))
	)
	(if (/= EXCELFILE nil)
		(progn
			(setq EXCELAPPLICATION (vlax-get-or-create-object "Excel.Application"))
			(vla-put-visible EXCELAPPLICATION :vlax-true)
			(vlax-put-property EXCELAPPLICATION 'DisplayAlerts :vlax-false)
			(setq 
				EXCELBOOK (vl-catch-all-apply 'vla-open (list (vlax-get-property EXCELAPPLICATION "WorkBooks") EXCELFILE))
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
		(prompt (strcat "\nFile Not Found: " (car EXCELDATAIN))) 
	)
	(vl-catch-all-apply 'vlax-invoke-method (list EXCELBOOK "Close"))
	(vl-catch-all-apply 'vlax-invoke-method (list EXCELAPPLICATION "Quit"))
	(vlax-release-object EXCELBOOK)
	(vlax-release-object EXCELAPPLICATION)
	(vlax-release-object EXCELSHEET)
	EXCELDATA
)