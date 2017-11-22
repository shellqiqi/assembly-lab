DATA SEGMENT
    INPUTNUM DB 0,0
    GUESSNUM DB 0,0
    GUESSTIME DW 0
    INPUTDIGITS DB 0
DATA ENDS
CODE SEGMENT PARA 'CODE'
    ASSUME CS:CODE, DS:DATA
    
MAIN PROC FAR
    CALL GET_INPUT
    CALL HIDE_NUMBER
    CALL GUESS_INPUT
    CALL SHOW_ANSWER
    JMP MAIN
MAIN ENDP

INC_GUESSTIME PROC NEAR
    ; MOV AX, DATA ; DEBUG
    MOV AX, 0080H ; PRODUCT
    MOV DS, AX
    MOV ES, AX
    LEA SI, GUESSTIME
    LEA DI, GUESSTIME
    CLD
    LODSW
    INC AL
    DAA
    XCHG AL, AH
    ADC AL, 0
    DAA
    XCHG AL, AH
    STOSW
    RET
INC_GUESSTIME ENDP

GUESS_INPUT PROC NEAR
    ; DISPLAY INPUT
    CALL GUESS_DISPLAY
    ; READ BUTTON
    MOV AH, 0
    INT 33H
    SUB AL, 10000B
    ; IF AVAILABLE
    CMP AL, 10
    JA GUESS_INPUT ; NO
    ; YES
    ; END IF
    ; IF PRESS A
    CMP AL, 0AH
    JNE INPUT_TWO ; NO
    RET ; YES
    ; END IF
INPUT_TWO:
    ; WRITE TO INPUTNUM
    XOR BX, BX
    MOV BL, BYTE PTR INPUTDIGITS
    ; MOV CX, DATA ; DEBUG
    MOV CX, 0080H ; PRODUCT
    MOV DS, CX
    MOV ES, CX
    LEA SI, INPUTNUM
    MOV BYTE PTR [BX][SI], AL
    INC BYTE PTR INPUTDIGITS
    ; IF INPUT TWO DIGITS
    CMP BYTE PTR INPUTDIGITS, 2
    JNE CLEAR_INPUT ; NO
    MOV BYTE PTR INPUTDIGITS, 0 ; YES
    ; END IF
    ; INCREASE GUESSTIME
    CALL INC_GUESSTIME
    CLD
    LEA SI, INPUTNUM
    LEA DI, GUESSNUM
    ; IF INPUT IS BIGGER
    CMPSB
    JA IS_BIGGER ; BIGGER
    JB IS_SMALLER ; SMALLER
    ; END IF
    ; IF INPUT IS BIGGER
    CMPSB
    JA IS_BIGGER ; BIGGER
    JB IS_SMALLER ; SMALLER
    RET ; EQUAL
    ; END IF
IS_BIGGER:
    MOV AH, 0
    MOV DX, 8000H
    INT 30H
    JMP GUESS_INPUT
IS_SMALLER:
    MOV AH, 0
    MOV DX, 0080H
    INT 30H
    JMP GUESS_INPUT
CLEAR_INPUT:
    LEA SI, INPUTNUM + 1
    ; LEA DI, INPUTNUM
    ; CLD
    ; MOV CX, 2
    ; MOV AL, 0
    ; REP STOSB
    MOV BYTE PTR [SI], 0
    JMP GUESS_INPUT
GUESS_INPUT ENDP

GUESS_DISPLAY PROC NEAR
    ; MOV AX, DATA ; DEBUG
    MOV AX, 0080H ; PRODUCT
    MOV DS, AX
    LEA SI, INPUTNUM
    MOV CL, 4
    CLD
    LODSB
    MOV DL, AL
    SHL DL, CL
    LODSB
    OR DL, AL
    MOV AH, 0
    MOV AL, 00111111B
    INT 32H
    MOV AH, 2
    INT 32H
    MOV AH, 1
    MOV DX, WORD PTR GUESSTIME
    INT 32H
    RET
GUESS_DISPLAY ENDP

SHOW_ANSWER PROC NEAR
    ; CLEAR LED
    MOV AH, 0
    MOV DX, 0
    INT 30H
    ; CLEAR TIME
    MOV AX, 0080H
    MOV DS, AX
    LEA SI, GUESSTIME
    MOV WORD PTR [SI], 0
    ; DISPLAY ANSWER
    ; MOV AX, DATA ; DEBUG
    MOV AX, 0080H ; PRODUCT
    MOV DS, AX
    MOV ES, AX
    LEA SI, GUESSNUM
    MOV CL, 4
    CLD
    LODSB
    MOV DL, AL
    SHL DL, CL
    LODSB
    OR DL, AL
    MOV AH, 0
    MOV AL, 00110000B
    INT 32H
    MOV AH, 2
    INT 32H
    ; READ BUTTON
    MOV AH, 0
    INT 33H
    SUB AL, 10000B
    ; IF AVAILABLE
    CMP AL, 10
    JA SHOW_ANSWER ; NO
    ; YES
    ; END IF
    ; CLEAR INPUTNUM
    MOV AL, 0
    LEA DI, INPUTNUM
    MOV CX, 2
    REP STOSB
    ; CLEAR GUESSNUM
    LEA DI, GUESSNUM
    MOV CX, 2
    REP STOSB
    RET
SHOW_ANSWER ENDP

HIDE_NUMBER PROC NEAR
    ; COPY TO GUESSNUM
    ; MOV BX, DATA ; DEBUG
    MOV BX, 0080H ; PRODUCT
    MOV DS, BX
    MOV ES, BX
    LEA SI, INPUTNUM
    LEA DI, GUESSNUM
    CLD
    MOV CX, 2
    REP MOVSB
    ; CLEAR INPUTNUM
    LEA DI, INPUTNUM
    MOV CX, 2
    MOV AL, 0
    REP STOSB
SET_ALL_F:
    ; SHOW FFFFFFFF
    MOV AH, 0
    MOV AL, 0FFFFH
    INT 32H
    MOV DX, 0FFFFH
    MOV AH, 1
    INT 32H
    MOV AH, 2
    INT 32H
    ; READ BUTTON
    MOV AH, 0
    INT 33H
    ; IF AVAILABLE
    SUB AL, 10000B
    CMP AL, 10
    JAE SET_ALL_F ; NO
    ; YES
    ; END IF
    LEA DI, INPUTNUM
    STOSB
    INC BYTE PTR INPUTDIGITS
    RET
HIDE_NUMBER ENDP

GET_INPUT PROC NEAR
    ; DISPLAY
    CALL INPUT_DISPLAY
    ; READ BUTTON
    MOV AH, 0
    INT 33H
    ; IF AVAILABLE
    SUB AL, 10000B
    CMP AL, 10
    JA GET_INPUT ; NO
    ; YES
    ; END IF
    ; IF PRESS A
    CMP AL, 0AH
    JNE INPUT_NUMBER ; NO
    RET ; YES
    ; END IF
INPUT_NUMBER:
    ; WRITE TO INPUTNUM
    ; MOV BX, DATA ; DEBUG
    MOV BX, 0080H ; PRODUCT
    MOV DS, BX
    MOV ES, BX
    LEA SI, INPUTNUM + 1
    LEA DI, INPUTNUM
    CLD
    MOVSB
    STOSB
    JMP GET_INPUT
GET_INPUT ENDP

INPUT_DISPLAY PROC NEAR
    ; MOV AX, DATA ; DEBUG
    MOV AX, 0080H ; PRODUCT
    MOV DS, AX
    LEA SI, INPUTNUM
    MOV CL, 4
    CLD
    LODSB
    MOV DL, AL
    SHL DL, CL
    LODSB
    OR DL, AL
    MOV AH, 0
    MOV AL, 00111111B
    INT 32H
    MOV AH, 2
    INT 32H
    MOV AH, 1
    MOV DX, 0FFFFH
    INT 32H
    RET
INPUT_DISPLAY ENDP

CODE ENDS
END MAIN
