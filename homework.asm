;*******************************
STRDISP MACRO _STRING                    ;显示字符串的宏
        LEA DX,_STRING
        MOV AH,09H
        INT 21H
        ENDM
;*************************  MAIN FUNCTION  ***************************
STACK SEGMENT STACK
DW   0FFH DUP(?)
TOP  LABEL  WORD
STACK ENDS


DATA  SEGMENT
MAINMENU DB 0DH,0AH,'PLEASE SELECT:',0DH,0AH,
            '1.TRANSFORM LOWER TO UPPER',0DH,0AH,
            '2.FIND THE MAX',0DH,0AH,
            '3.TRANSFORM DEC TO HEX AND SORT(UNDONE)',0DH,0AH,
            '4.CHANGE TIME',0DH,0AH,
            '5.EXIT',0DH,0AH,
            'INPUT YOUR CHOICE:$'
STRSUB1   DB 0DH,0AH,'PLEASE INPUT STRING:',0DH,0AH,'$'
STRSUB2   DB 'PRESS Esc TO EXIT,PRESS ANYHEY TO CONTINUE...','$'
STRBUF    DB 40H DUP(?)

TABLE         DW PROC1                         ;跳转表
              DW PROC2
              DW PROC3
              DW PROC4
              DW PROC5
CLRF          DB 0DH,0AH,'$'
DATA ENDS

CODEM SEGMENT
      ASSUME CS:CODEM,DS:DATA,SS:STACK,ES:DATA
MAIN: MOV AX,DATA
      MOV DS,AX
AGAIN:strdisp mainmenu                    ;显示主菜单
      MOV AH,01H                          ;读入用户选择
      INT 21H
      SUB AL,30H                            ;将字符转换为数字
      CMP AL,1
      JB  AGAIN
      CMP AL,5
      JA  AGAIN
      SUB AL,1
      SHL AL,1
      CBW
      MOV BX,AX
      JMP TABLE[BX]

PROC1:CALL FAR PTR UPPER           ;CALL PROC1
      JMP AGAIN
PROC2:CALL FAR PTR MAXIMUM          ;CALL PROC2
      JMP AGAIN
PROC3:NOP                                        ;CALL PROC3
      JMP AGAIN
PROC4:CALL FAR PTR SETTIME             ;CALL PROC4
      JMP AGAIN
PROC5:JMP EXIT
EXIT: MOV AH,4CH
      INT 21H
CODEM ENDS

 
;****************************  SUBFUNCTION 1  ****************************
CODE1 SEGMENT
      ASSUME CS:CODE1,DS:DATA
UPPER PROC FAR
      PUSH DX
      PUSH CX
      PUSH BX
      PUSH AX
      PUSH SI
      PUSH DI
      MOV AX,DATA
      MOV DS,AX
AGAIN1:STRDISP STRSUB1                    ;输出'PLEASE INPUT STRING:'
      MOV BYTE PTR STRBUF,40H
      LEA DX,STRBUF
      MOV AH,0AH                                ;输入字符串到strbuf
      INT 21H
      MOV AL,STRBUF+1                      ;取串长
      add al,1
      CBW
      LEA SI,STRBUF+2
      ADD SI,AX
      MOV BYTE PTR [SI],'$'
      MOV CX,AX
LOOP1:MOV BX,CX                                 ;循环减小写字母转换为大写字母
      CMP BYTE PTR STRBUF[BX],'a'
      JB  DONE
      CMP BYTE PTR STRBUF[BX],'z'
      JA  DONE
      SUB BYTE PTR STRBUF[BX],20H
DONE: LOOP LOOP1                               ;循环
      STRDISP CLRF                             ;回车换行
      LEA DX,STRBUF+2
      MOV AH,09H                                 ;输出转换后的字符串
      INT 21H
      STRDISP CLRF
      STRDISP STRSUB2
      MOV AH,07H
      INT 21H
      CMP AL,01BH                                ;判断用户输入是否是Esc
      JZ  EXIT1                                    ;是则退出子程序
      JMP AGAIN1
EXIT1:POP DI
      POP SI
      POP AX
      POP BX
      POP CX
      POP DX
      RET
UPPER ENDP
CODE1 ENDS


;***************************  SUB FUNCTION 2  *****************************
SUB2DATA SEGMENT
SUB2STR1 DB 'PLEASE INPUT STRING:',0DH,0AH,'$'
SUB2STR2 DB 'PRESS Esc TO EXIT,PRESS ANYKEY TO CONTINUE...$'
SUB2STR3 DB 'THE MAXIMUM IS: $'
SUB2STR4 DB 0DH,0AH,'$'
SUB2BUF  DB 40H DUP(?)
SUB2DATA ENDS

CODE2 SEGMENT
      ASSUME CS:CODE2,DS:SUB2DATA,ES:SUB2DATA
MAXIMUM PROC FAR
      PUSH DX
      PUSH CX
      PUSH BX
      PUSH AX
      PUSH DS
      PUSH ES
      PUSH SI
      PUSH DI
      MOV AX,SUB2DATA
      MOV DS,AX
      MOV ES,AX
SUB2AGAIN:
      STRDISP SUB2STR4                            ;输出回车换行
      STRDISP SUB2STR1                            ;输出'PLEASE INOUT STRING:'

      MOV BYTE PTR SUB2BUF,40H
      LEA DX,SUB2BUF
      MOV AH,0AH                                ;输入字符串到SUB2BUF
      INT 21H

      MOV AL,SUB2BUF+1
      CBW
      MOV CX,AX                                 ;取字符串的长度

      LEA SI,SUB2BUF+2
      ADD SI,AX
      MOV BYTE PTR [SI],'$'
      LEA DI,SUB2BUF+2
      sub di,1
      MOV AL,0
      cld
LOOPSUB2:SCASB       ;扫描字符串，SCASB 用AL的值减去ES:[DI]指向的值设置标志位
      cmp al,es:[di]
      Ja  LOOPSUB2END               ;AL>ES:[DI]则跳转到LOOPSUB2END
      MOV AL,ES:[DI]                     ;AL<ES:[DI]则用ES:[DI]代替AL
LOOPSUB2END:LOOP LOOPSUB2
      cbw
      push ax
      STRDISP SUB2STR4                     ;输出回车换行
      STRDISP SUB2STR3                     ;输出'THE MAXIMUM IS: $'
      pop ax
      mov dl,al
      MOV AH,02H                          ;输出最大字符
      INT 21H

      STRDISP SUB2STR4                     ;输出回车换行
      STRDISP SUB2STR2                     ;输出结束提示
      MOV AH,07H                          ;读取按键
      INT 21H
      CMP AL,01BH                         ;与 Esc 比较
      JZ EXIT2                               ;是 则退出
      JMP SUB2AGAIN                    ;否 则跳到开始,循环

EXIT2:POP DI
      POP SI
      POP ES
      POP DS
      POP AX
      POP BX
      POP CX
      POP DX
      RET
MAXIMUM ENDP
CODE2 ENDS

;*******************************
TRANS MACRO _SEG,_MEMO                        ;宏：将二进制数转换为数字字符
      MOV AL,_SEG
      CBW
      DIV TEN
      ADD AH,THIRTY
      ADD AL,THIRTY
      MOV _MEMO,AL
      MOV _MEMO+1,AH
      ENDM
DECTOBIN MACRO _MEMORY,_SEGMENT    ;宏：将两位的十进制数转换为二进制
      MOV AL,_MEMORY
      SUB AL,THIRTY
      MUL BYTE PTR TEN
      ADD AL,_MEMORY+1
      SUB AL,THIRTY
      MOV _SEGMENT,AL
      ENDM
;******************************* SETTIME *******************************
SUB4DATA SEGMENT
HOUR            DB '00$'
MINUTE        DB '00$'
SECOND       DB '00$'
COLON         DB ':$'
TEN                     DB 10D
THIRTY         DB 30H
SUB4STR1     DB 'TIME:$'
STREND DB 'PRESS Esc TO EXIT,PRESS ANYOTHER KEY TO CONTINUE...$'
CLRF4           DB 0DH,0AH,'$'
TIMEBUF      DB 12,8,'HH:MM:SS$'
SUBSTR2  DB 'PLEASE INPUTT THE TIME(HH:MM:SS):$'
SUBSTR3  DB 'DO YOU WANT TO RESET TIME(Y/N)?$'
SUBSTR4  DB 'SETTIME ERROR$'
SUB4DATA ENDS

CODE4 SEGMENT
ASSUME CS:CODE4,DS:SUB4DATA,ES:SUB4DATA
SETTIME PROC FAR
      PUSH DX
      PUSH CX
      PUSH BX
      PUSH AX
      PUSH DS
      PUSH ES
      PUSH SI
      PUSH DI
      MOV AX,SUB4DATA
      MOV DS,AX
      MOV ES,AX
SUB4AGAIN:
        STRDISP CLRF4
        MOV AH,2CH                      ;取系统时间
        INT 21H

        TRANS CH,HOUR
        TRANS CL,MINUTE
        TRANS DH,SECOND

        STRDISP SUB4STR1                  ;显示时间
        STRDISP HOUR
        STRDISP COLON
        STRDISP MINUTE
        STRDISP COLON
        STRDISP SECOND

        STRDISP CLRF4
        STRDISP SUBSTR3

        MOV AH,01                                ;INPUT A LETTER INTO AL
        INT 21H
        CMP AL,'Y'
        JE  RESETTIME
        CMP AL,'y'
        JNE NORESETTIME                  ;IF AL IS NOT 'Y' OR 'y' THEN END
RESETTIME:
        STRDISP CLRF4
        STRDISP SUBSTR2
        LEA DX,TIMEBUF
        MOV AH,0AH                      ;INPUT THE TIME STRING
        INT 21H
        DECTOBIN TIMEBUF+2,CH
        DECTOBIN TIMEBUF+5,CL
        DECTOBIN TIMEBUF+8,DH
        MOV AH,2DH                      ;SET TIME
        INT 21H

        CMP AL,0                                  ;判断是否设置成功
        JZ SUB4AGAIN                          ;AL为00则成功，为0FF则失败
        STRDISP CLRF4
        STRDISP SUBSTR4                    ;显示出错信息
        JMP SUB4AGAIN
NORESETTIME:
        STRDISP CLRF4
        STRDISP STREND

      MOV AH,07H                                 ;读取按键
      INT 21H
      CMP AL,01BH                                ;与 Esc 比较
      JZ EXIT4                                      ;是 则退出
      JMP SUB4AGAIN                           ;否 则跳到开始,循环
EXIT4:POP DI
      POP SI
      POP ES
      POP DS
      POP AX
      POP BX
      POP CX
      POP DX
      RET
SETTIME ENDP
CODE4 ENDS
      END MAIN
