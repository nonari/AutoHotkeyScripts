; Copyright 2016 nonari Corp.

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;The number variable names here represent itself the number of shares to be
;placed on order and it's internal value the current share price

;SAN
0900 = 3.665
;BBVA
0600 = 5.52
;POP
1500 = 2.104
;BKIA
4000 = 0.798
;SAB
2100 = 1.475
;REP
0360 = 9.34
;MAP
;1500 = 2.01

;This coefficient determinates the limit prices for the orders following this formula:
;Limit_Order_Idx = Current_Price * (Stop * Ceil(Idx/2) * (-1^Idx) + 1) where Idx is the
;counter inside the Loop placing the orders. Should be read as: percentage from the
;curent price at which the limit order will be placed.
Stop := 0.0155

;The Take Profit Coefficient determinates the price at which, an already placed order, will
;be automatically sold to take profit.
TPL := 0.025

;Delay between sent keystrokes (in ms). The smaller this number is the more probabilities
;the window receiving the keys to skip some of them.
DELAY = 250

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Received number string
GG := ""

;Loop creating hotkeys for 0-9
Loop, 10 {
    HotStr := "$" . Chr(A_Index + 47)
    Hotkey, %HotStr%,Append
}

Check:
    If StrLen(GG) = 4 {
        If (%GG% = ""){
            MsgBox String not found
            GG := ""
            Return
        }
        C_Stop := Stop
        C_TPL := TPL
        Price := % %GG%
        ;Force conversion to int and remove leading zeroes
        Qtty := GG * 1
        GG := ""

        Loop, 4 {
            SetFormat, float, 5.3
            C_Stop := C_Stop * -1
            C_Price := Price * (C_Stop + 1)
            Sleep, %DELAY%
            Send ^a
            Sleep, %DELAY%
            Send %Qtty%
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send ^a
            Sleep, %DELAY%
            Send %C_Price%
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send ^a
            Sleep, %DELAY%
            CS_Price := Price * C_TPL
            Send %CS_Price%
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send {Tab}
            If Mod(A_Index, 2) = 0 {
                C_TPL := C_TPL + Stop
                C_Stop := C_Stop + Stop
                SetFormat, float, 5
                Qtty := Qtty * 0.66
                Sleep, %DELAY%
                Send {Enter}
                Sleep, %DELAY%
                Sleep, %DELAY%
                Sleep, %DELAY%
                Loop, 8 {
                    Sleep, %DELAY%
                    Send {Tab}
                }
            } else {
            Sleep, %DELAY%
            Send {Tab}
            Sleep, %DELAY%
            Send {Enter}
            Sleep, %DELAY%
            Sleep, %DELAY%
            Sleep, %DELAY%
                Loop, 7 {
                    Sleep, %DELAY%
                    Send {Tab}
                }
            }
        }

    }
Return

Append:
    GG := GG . Substr(A_ThisHotkey, 2, 1)
    GoTo, Check
Return
