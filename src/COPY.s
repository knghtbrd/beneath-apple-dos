 SBTL 'C O P Y -- CONVERT FILES'
 ORG $800
 SKP 1
***********************************************************
*                                                         *
* COPY:THIS PROGRAM DEMONSTRATES THE USE OF THE DOS FILE  *
*      MANAGER BY COPYING A BINARY FILE TO A TEXT FILE.   *
*                                                         *
* INPUT: INPUT FILE NAME IS "INPUT"                       *
*        OUTPUT FILE NAME IS "OUTPUT"                     *
*                                                         *
* ENTRY POINT: $800                                       *
*                                                         *
* PROGRAMMER: DON D WORTH 2/19/81                         *
*                                                         *
***********************************************************
 SKP 2
BELL EQU $87 BELL CHARACTER
 SKP 1
*       ZPAGE DEFINITIONS
 SKP 1
PTR EQU $0 WORK POINTER
BUFP EQU $2 BUFFER POINTER
EBYTE EQU $4
A1L EQU $3C MONITOR POINTER
A2L EQU $3E MONITOR POINTER
 SKP 1
*       OTHER ADDRESSES
 SKP 1
BUFFER EQU $1000 DATA BUFFER
DOSWRM EQU $3D0 DOS WARMSTART ADDRESS
LOCRPL EQU $3E3 LOCATE RWTS PARMLIST SUBRTN
LOCFPL EQU $3DC LOCATE FILE MGR PARMLIST SUB
FM EQU $3D6 FILE MANAGER ENTRY POINT
COUT EQU $FDED PRINT ONE CHAR SUBROUTINE
PRBYTE EQU $FDDA PRINT ONE HEX BYTE SUBRTN
 SKP 1
*       FILE MANAGER PARMLIST DEFINITION
 SKP 1
 DSECT
FMOCOD DS 1 OPERATION CODE
FMOCOP EQU $01    OPEN
FMOCCL EQU $02    CLOSE
FMOCRD EQU $03    READ
FMOCWR EQU $04    WRITE
FMOCDE EQU $05    DELETE
FMOCCA EQU $06    CATALOG
FMOCLO EQU $07    LOCK
FMOCUN EQU $08    UNLOCK
FMOCRE EQU $09    RENAME
FMOCPO EQU $0A    POSITION
FMOCIN EQU $0B    INIT
FMOCVE EQU $0C    VERIFY
FMSBCD DS 1 SUBCODE
FMSBNO EQU $00    NO OPERATION
FMSBON EQU $01    READ/WRITE ONE BYTE
FMSBRA EQU $02    READ/WRITE RANGE OF BYTES
FMSBPO EQU $03    POSITION AND DO ONE BYTE
FMSBPR EQU $04    POSITION AND DO RANGE
FMPRMS DS 8 SPECIFIC PARAMETERS
 SKP 1
*       OPEN PARMS
 ORG FMPRMS
FMRCLN DS 2 RECORD LENGTH
FMVOL DS 1 VOLUME
FMDRV DS 1 DRIVE
FMSLT DS 1 SLOT
FMTYPE DS 1 TYPE
FMTYPT EQU 0    TEXT
FMTYPI EQU 1    INTEGER
FMTYPA EQU 2    APPLESOFT
FMTYPB EQU 4    BINARY
FMNAME DS 2 ADDRESS OF FILE NAME
 SKP 1
*       READ/WRITE PARMS
 ORG FMPRMS
FMRCNM DS 2 RECORD NUMBER
FMOFFS DS 2 BYTE OFFSET
FMRALN DS 2 RANGE LENGTH
FMRAAD DS 2 RANGE ADDRESS
FMDATA EQU FMRAAD DATA BYTE READ/WRITTEN
 SKP 1
*       RENAME PARMS
 ORG FMPRMS
FMNNAM DS 2 ADDRESS OF NEW NAME
 SKP 1
*       INIT PARMS
 ORG FMPRMS
FMPAGE EQU FMSBCD FIRST PAGE OF DOS IMAGE
 SKP 1
*       COMMON PARMS
 ORG FMPRMS+8
FMRC DS 1 RETURN CODE
FMRCOK EQU 0    NO ERRORS
FMRCBO EQU 2    BAD OPCODE
FMRCBS EQU 3    BAD SUBCODE
FMRCWP EQU 4    WRITE PROTECTED
FMRCED EQU 5    END OF DATA
FMRCNF EQU 6    FILE NOT FOUND
FMRCBV EQU 7    BAD VOLUME
FMRCIO EQU 8    I/O ERROR
FMRCDF EQU 9    DISK FULL
FMRCLK EQU 10    FILE LOCKED
 DS 1 NOT USED
FMFMWA DS 2 FILE MANAGER WORKAREA PTR
FMTSL DS 2 T/S LIST PTR
FMBUFF DS 2 DATA BUFFER PTR
 DEND
 PAGE
*       LOCATE FM PARMLIST
 SKP 1
COPY JSR LOCFPL FIND PARMLIST
 STY PTR SET UP POINTER TO IT
 STA PTR+1
 SKP 1
*       OPEN INPUT FILE
 SKP 1
 LDY #FMNAME STORE INPUT FILE NAME 
 LDA #>INAME PTR IN LIST
 STA (PTR),Y
 INY
 LDA #<INAME
 STA (PTR),Y
 LDY #FMTYPE BINARY FILE AS INPUT
 LDA #FMTYPB
 STA (PTR),Y
 LDX #1 OLD FILE EXPECTED
 JSR OPEN AND OPEN THE FILE
 BCC INOP
 JMP ERROR ANY ERROR IS FATAL
 SKP 1
INOP LDA BUFP
 STA IBUFF SAVE OPEN FILE BUFFER
 LDA BUFP+1
 STA IBUFF+1
 JSR REWIND POSITION TO START OF FILE
 SKP 1
*       OPEN OUTPUT FILE
 SKP 1
 LDY #FMNAME STORE OUTPUT FILE NAME
 LDA #>ONAME PTR IN LIST
 STA (PTR),Y
 INY
 LDA #<ONAME
 STA (PTR),Y
 LDY #FMTYPE TEXT FILE AS OUTPUT
 LDA #FMTYPT
 STA (PTR),Y
 LDX #0 NEW FILE IS OK
 JSR OPEN
 BCC OUTOP
 LDY #FMRC
 LDA (PTR),Y
 CMP #FMRCNF FILE NOT FOUND?
 BEQ OUTOP YES, WAS ALLOCATED THEN
 JMP ERROR
 SKP 1
OUTOP LDA BUFP SAVE OPEN OUTPUT FILE BUFFER
 STA OBUFF
 LDA BUFP+1
 STA OBUFF+1
 JSR REWIND POSITION TO START OF FILE
 SKP 1
*       READ ADDRESS/LENGTH FROM BINARY FILE
 SKP 1
 LDA #4 READ 4 BYTES FIRST
 LDY #FMRALN
 STA (PTR),Y
 LDA #0
 INY
 STA (PTR),Y
 JSR READ
 SKP 1
*       READ ENTIRE BINARY FILE INTO MEMORY AT $1000
 SKP 1
 LDA BUFFER+2 COPY DATA LENGTH TO LIST
 LDY #FMRALN
 STA (PTR),Y
 LDA BUFFER+3
 INY
 STA (PTR),Y
 CLC 
 LDA BUFFER+2 COMPUTE ENDING BYTE
 PHA
 ADC #>BUFFER
 STA EBYTE
 LDA BUFFER+3
 PHA
 ADC #<BUFFER
 STA EBYTE+1
 JSR READ READ BLOB INTO MEMORY
 SKP 1
*       WRITE ENTIRE BLOB OUT INTO TEXT FILE
 SKP 1
 LDY #0
 TYA
 STA (EBYTE),Y MARK END OF FILE
 PLA
 LDY #FMRALN+1 SET RANGE LENGTH
 STA (PTR),Y
 DEY
 PLA
 STA (PTR),Y
 JSR WRITE WRITE BLOB FROM MEMORY
 SKP 1
*       WHEN FINISHED, CLOSE FILES
 SKP 1
EXIT LDA OBUFF
 STA BUFP
 LDA OBUFF+1
 STA BUFP+1
 JSR CLOSE CLOSE OUTPUT FILE
 LDA IBUFF
 STA BUFP
 LDA IBUFF+1
 STA BUFP+1
 JSR CLOSE CLOSE INPUT FILE
 JMP DOSWRM BACK TO DOS
 SKP 1
*       ERROR, PRINT "ERRXX"   
 SKP 1
ERROR LDY #FMRC FIND RETURN CODE
 LDA (PTR),Y
 PHA
ERR LDA #'E PRINT "ERR"
 JSR COUT
 LDA #'R
 JSR COUT
 JSR COUT
 PLA
 JSR PRBYTE PRINT HEX CODE
 BRK  DIE HORRIBLY
 SKP 1
*       OPEN: COMPLETE PARMLIST AND OPEN FILE
 SKP 1
OPEN LDA DOSWRM+2 FIND DOS ENTRY
 STA BUFP+1
 LDY #0
 STY BUFP POINT AT BUFFER CHAIN
 SKP 1
*       SCAN DOS BUFFERS FOR A FREE ONE
 SKP 1
GBUF0 LDA (BUFP),Y LOCATE NEXT DOS BUFFER
 PHA
 INY
 LDA (BUFP),Y
 STA BUFP+1
 PLA
 STA BUFP
 BNE GBUF GOT ONE
 LDA BUFP+1
 BNE GBUF GOT ONE
 SKP 1
 LDA #12 NO FILE BUFFERS RETURN CODE
 PHA
 JMP ERR GO PRINT MESSAGE
 SKP 1
GBUF LDY #0 LOOK AT FILENAME
 LDA (BUFP),Y
 BEQ GOTBUF NONE THERE, FREE BUFFER
 LDY #36 IT'S NOT FREE
 BNE GBUF0 GO GET NEXT ONE
 SKP 1
GOTBUF LDA #1
 STA (BUFP),Y MARK BUFFER IN USE
 SKP 1
*       FINISH COMPLETING OPEN LIST
 SKP 1
 LDY #FMOCOD
 LDA #FMOCOP
 STA (PTR),Y SET OPCODE TO OPEN
 LDA #0
 LDY #FMRCLN
 STA (PTR),Y SET RECORD LENGTH TO 0
 INY
 STA (PTR),Y
 LDY #FMVOL
 STA (PTR),Y AND VOLUME (ANY VOL)
 SKP 1
 JSR LOCRPL FIND RWTS PARMS
 STY A1L
 STA A1L+1  
 LDY #1
 LDA (A1L),Y GET SLOT*16
 LSR A
 LSR A
 LSR A
 LSR A SLOT=SLOT/16
 LDY #FMSLT
 STA (PTR),Y STORE IN LIST
 LDY #2
 LDA (A1L),Y GET DRIVE
 LDY #FMDRV
 STA (PTR),Y AND SLOT
 SKP 1
*       COMMON INTERFACE TO FILE MANAGER
 SKP 1
CALLFM LDY #30
CFMLP1 LDA (BUFP),Y GET THREE BUFFER PTRS
 PHA
 INY
 CPY #36
 BCC CFMLP1
 SKP 1
 LDY #FMBUFF+1
CFMLP2 PLA
 STA (PTR),Y COPY THEM TO FM LIST
 DEY
 CPY #FMFMWA
 BCS CFMLP2
 SKP 1
 JMP FM EXIT THRU FILE MANAGER
 SKP 1
*       CLOSE: CLOSE DOS FILE
 SKP 1
CLOSE LDY #FMOCOD 
 LDA #FMOCCL
 STA (PTR),Y
 JSR CALLFM CLOSE FILE
 BCC CLOK
 JMP ERROR
CLOK LDY #0 FREE BUFFER
 TYA
 STA (BUFP),Y
 RTS
 SKP 1
*       REWIND: POSITION TO START OF FILE
 SKP 1
REWIND LDY #FMRCNM
 LDA #0
REWLP STA (PTR),Y ZERO RECORD NUMBER AND..
 INY
 CPY #FMOFFS+2 BYTE OFFSET.
 BCC REWLP
 LDY #FMOCOD
 LDA #FMOCPO POSITION OPCODE
 STA (PTR),Y
 JSR CALLFM EXIT VIA FILE MANAGER
 BCC REWRTS CHECK FOR ERRORS
 JMP ERROR
REWRTS RTS
 SKP 1
*       READ: READ A RANGE OF BYTES TO $1000
 SKP 1
READ LDA IBUFF FIND PROPER BUFFER
 STA BUFP
 LDA IBUFF+1
 STA BUFP+1
 LDA #FMOCRD READ OPCODE
 BNE DOIO GO DO COMMON CODE
 SKP 1
*       WRITE: WRITE A RANGE OF BYTES FROM $1000
 SKP 1
WRITE LDA OBUFF FIND PROPER BUFFER
 STA BUFP
 LDA OBUFF+1
 STA BUFP+1
 LDA #FMOCWR WRITE OPCODE
*       BNE     DOIO
 SKP 1
*       DOIO: READ/WRITE A RANGE OF BYTES
 SKP 1
DOIO LDY #FMOCOD
 STA (PTR),Y SET OPCODE
 LDY #FMSBCD
 LDA #FMSBRA
 STA (PTR),Y DO RANGE OF BYTES
 LDY #FMRAAD
 LDA #>BUFFER
 STA (PTR),Y RANGE ADDRESS=$1000
 INY
 LDA #<BUFFER
 STA (PTR),Y
 JSR CALLFM CALL FM TO DO I/O OPERATION
 BCC DOIORT
 JMP ERROR
DOIORT RTS
 PAGE
*       DATA
 SKP 1
INAME ASC 'INPUT                         '
ONAME ASC 'OUTPUT                        '
 SKP 1
OBUFF DS 2
IBUFF DS 2
\x00 '
 SKP 1
OBUFF DS 2
IBUFF DS 2
\x00                       '
 SKP 1
OBUFF DS 2
IBUFF DS 2