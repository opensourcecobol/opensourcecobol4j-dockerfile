all:
	ocesql INSERTTBL.cbl INSERTTBL.cob
	ocesql FETCHTBL.cbl FETCHTBL.cob
	cobj *.cob
	java INSERTTBL
	java FETCHTBL
