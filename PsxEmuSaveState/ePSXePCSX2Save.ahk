; Copyright 2016 nonari Corp.

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; As AutoHotkeyScript is unable to "retain" a gamepad input, its necessary to
; bypass the emulator input buttons through the script to avoid native key
; effects. This script makes use of the keys h, j, u, k, i that have to be mapped
; at the emulator gamepad configuration as described below.
; SELECT -> h
; L1 -> j
; L2 -> u
; R1 -> k
; R2 -> i

; Set the variables with the absolute path to your emulators excutable
; This script may also fit any other emulator making use of a PSX/2 like gamepad
; If adding additional emulators remember to append the variable name you choose
; to the list adding a line below the 48th with the format:
; GuiControl,, Emulator, {yourNewEmulatorVarName}
epsxe = ePSXe\ePSXe.exe
pcsx2 = PCSX2 1.2.1\pcsx2-r5875.exe

; This delay (in ms) may give the chance to avoid the native effect of the R1 and
; R2 keys if both pressed within the time specified. Notice that increasing delay
; will also retard the native function of these keys to take effect.
DELAY = 200

; DON'T use this feature in fullscreen mode.
; Setting BELL_SOUND to 1 will cause the ASCII Bell sound to ring when saving game
; state. As the trick makes use of a minimized command line window this may cause
; the game to quit when in fullscreen mode.
BELL_SOUND = 0

; PSX/2 gamepad
; Change the values on the right to match your own game pad key mapping, although
; default values are the standart of a PSX/2 gamepad.
L1 = 5
L2 = 6
R1 = 7
R2 = 8
SLCT = 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gui, Add, Text,, Select the emulator from the list below
Gui, Add, ListBox, vEmulator gListBox w200 r10
GuiControl,, Emulator, ePSXe
GuiControl,, Emulator, pcsx2

L1 = Joy%L1%
L2 = Joy%L2%
R1 = Joy%R1%
R2 = Joy%R2%
SLCT = Joy%SLCT%

;Create dinamic hotkeys based on config mapping
Hotkey, %L1%, Handle_L1
Hotkey, %L2%, Handle_L2
Hotkey, %R1%, Handle_R1
Hotkey, %R2%, Handle_R2
Hotkey, %SLCT%, Handle_SLCT

Gui, Show

ListBox:
    If A_GuiEvent <> DoubleClick
        Return
    ; Retrieve the ListBox current selection.
    GuiControlGet, Emulator
    ; Get the emulator exe PATH
    emuPath = % %Emulator%
    ; MsgBox %emuPath%
    Run, %emuPath%,, UseErrorLevel, PID

    If (ErrorLevel = ERROR){
        MsgBox %emuPath% not found.
        Return
    }

    SetTimer, CheckIfExited
    Gui, Hide
Return

; Checks if the emulator process has exited
CheckIfExited:
    ;If the emulator is still running the env var ErrorLevel is set to program's PID
    Process, Exist ,%PID%
    IfNotEqual, ErrorLevel, %PID%, ExitApp
    Return


; Load save state pressing L1 while holding R1+R2
Handle_L1:
    ; If hotkey combination is being pressed this code triggers the hotkey function
    If GetKeyState(R1){
        If GetKeyState(R2){
            ; The emulator requires to simulate the keypress event for the comands to take effect
            SendInput {F3 down}
            Sleep, 25
            SendInput {F3 up}
            Return
        }
    }
    ; This triggers the native key function
    SendInput {j down}
    Sleep, 25
    While(1){
        If !GetKeyState(L1){
            SendInput {j up}
            Return
        }
        Sleep, 25
    }
    Return

; Toggle framelimit pressing Select while holding R1+R2
Handle_SLCT:
    If GetKeyState(R1){
        If GetKeyState(R2){
            SendInput {F4 down}
            Sleep, 55
            SendInput {F4 up}
            Return
        }
    }
    SendInput {h down}
    Sleep, 25
    While(1){
        If !GetKeyState(SLCT){
            SendInput {h up}
            Return
        }
        Sleep, 25
    }
    Return

; Save state pressing L2 while holding R1+R2
Handle_L2:
    If GetKeyState(R1){
        If GetKeyState(R2){
            SendInput {F1 down}
            Sleep, 25
            SendInput {F1 up}
            ; Ring the bell if activated
            If BELL_SOUND{
                ;Run a command interpreter
                Run,%comspec%,,Min, BELL_PID
                ; Let the program to be ready
                Sleep, 100
                ControlSend,,^g{Enter}, ahk_pid %BELL_PID%
                ; Let the sound to ring for a second
                Sleep, 1000
                ; Close the interpreter
                Process, Close, %BELL_PID%
            }
            Return
        }
    }
    SendInput {u down}
    Sleep, 25
    While(1){
        If !GetKeyState(L2){
            SendInput {u up}
            Return
        }
        Sleep, 25
    }
    Return

; Disable R1 function while R2 pressed
Handle_R1:
    Sleep, 100
    ; If R2 is not being pressed at the same time let the native R1 function to take effect
    If !GetKeyState(R2){
        SendInput {k down}
        Sleep, 25
        ; Hold the key pressed until is released or R2 is also pressed
        While(1){
            If !GetKeyState(L2) || !GetKeyState(R2) {
                SendInput {k up}
                Return
            }
            Sleep, 25
        }
    }
    Return

; Disable R2 function while R1 pressed
Handle_R2:
    Sleep, 100
    If !GetKeyState(R1){
        SendInput {i down}
        Sleep, 25
        While(1){
            If !GetKeyState(R1) || !GetKeyState(R2) {
                SendInput {i up}
                Return
            }
            Sleep, 25
        }
    }
    Return

    GuiClose:
    GuiEscape:
    ExitApp

Return
