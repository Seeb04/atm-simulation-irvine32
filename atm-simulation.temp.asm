INCLUDE c:\Users\Haseeb\.vscode\extensions\istareatscreens.masm-runner-0.9.1\native\irvine\Irvine32.inc

.data
    ;Account Data
    systemPIN       DWORD 1234 ; The correct PIN (initially 1234)
    currentBalance  SDWORD 1000 ; Start with 1000
    userChoice      DWORD ?         
    tempAmount      SDWORD ? ; For deposits/withdrawals
    tempPinInput    DWORD ? ; For PIN verification

    ;Interface
    strTitle        BYTE "=====================================", 0dh, 0ah
                    BYTE "      AUTOMATED BANKING SYSTEM        ", 0dh, 0ah
                    BYTE "=====================================", 0

    strPinPrompt    BYTE "ENTER YOUR 4-DIGIT PIN: ", 0
    strWelcome      BYTE "Access Granted. Welcome, User.", 0dh, 0ah, 0
    strInvalidPin   BYTE "Incorrect PIN. Please try again.", 0dh, 0ah, 0

    strMenu         BYTE 0dh, 0ah, "--- MAIN MENU ---", 0dh, 0ah
                    BYTE "1. Check Balance", 0dh, 0ah
                    BYTE "2. Deposit Money", 0dh, 0ah
                    BYTE "3. Withdraw Money", 0dh, 0ah
                    BYTE "4. Change PIN", 0dh, 0ah
                    BYTE "5. Logout / Exit", 0dh, 0ah
                    BYTE "Choose an option > ", 0
    
    ; Transaction Messages
    strBalMsg       BYTE "Current Balance: $", 0
    strDepMsg       BYTE "Enter amount to deposit: $", 0
    strWithMsg      BYTE "Enter amount to withdraw: $", 0
    strNewBal       BYTE "Transaction Complete. New Balance: $", 0
    strErrFunds     BYTE "ERROR: Insufficient funds!", 0dh, 0ah, 0
    strErrInput     BYTE "ERROR: Invalid input or negative amount.", 0dh, 0ah, 0
    
    ;PIN Change Messages
    strNewPin       BYTE "Enter your NEW 4-digit PIN: ", 0
    strConfirm      BYTE "Confirm your NEW PIN: ", 0
    strPinSuccess   BYTE "SUCCESS: Your PIN has been changed.", 0dh, 0ah, 0
    strPinFail      BYTE "ERROR: PINs did not match. PIN was not changed.", 0dh, 0ah, 0
    strLogout       BYTE "Logging out...", 0

.code
main PROC
    ; LOGIN SCREEN
    LoginLoop:
        call Clrscr
        mov edx, OFFSET strTitle
        call WriteString
        call Crlf

        mov edx, OFFSET strPinPrompt
        call WriteString

        call ReadInt ; Input goes into EAX
        cmp eax, systemPIN ; Compare Input vs Current System PIN
        je LoginSuccess ; if successfully matched, jump to login success

        ; incorrect PIN sequence
        mov edx, OFFSET strInvalidPin
        call WriteString
        call WaitMsg ; pause for user to read
        jmp LoginLoop; restart login

    LoginSuccess:
        mov edx, OFFSET strWelcome
        call WriteString
        call WaitMsg

    ; MAIN MENU LOOP
    MenuLoop:
        call Clrscr
        mov edx, OFFSET strTitle
        call WriteString

        mov edx, OFFSET strMenu
        call WriteString

        call ReadInt
        mov userChoice, eax

        ;switch case logic
        cmp eax, 1 ; check balance
        je OpBalance
        cmp eax, 2 ; deposit
        je OpDeposit
        cmp eax, 3 ; withdraw
        je  OpWithdraw
        cmp eax, 4 ; change pin
        je OpChangePin
        cmp eax, 5 ; logout/exit
        je OpLogout

        jmp MenuLoop ; Invalid input loops back

    ; OPTION 1: CHECK BALANCE
    OpBalance:
        call Crlf
        mov edx, OFFSET strBalMsg
        call WriteString
        mov eax, currentBalance
        call WriteDec
        call Crlf
        call WaitMsg
        jmp MenuLoop

    ; OPTION 2: DEPOSIT
    OpDeposit:
        call Crlf
        mov edx, OFFSET strDepMsg
        call WriteString
        call ReadInt

        cmp eax, 0
        jl InputError

        add currentBalance, eax

        mov edx, OFFSET strNewBal
        call WriteString
        mov eax, currentBalance
        call WriteDec
        call Crlf
        call WaitMsg
        jmp MenuLoop

    ; OPTION 3: WITHDRAWAL
    OpWithdraw:
        call Crlf
        mov edx, OFFSET strWithMsg
        call WriteString
        call ReadInt
        mov tempAmount, eax

        cmp eax, 0
        jl InputError

        cmp eax, currentBalance
        jg InsufficientFunds

        mov eax, tempAmount
        sub currentBalance, eax

        mov edx, OFFSET strNewBal
        call WriteString
        mov eax, currentBalance
        call WriteDec
        call Crlf
        call WaitMsg
        jmp MenuLoop
    ; OPTION 4: CHANGE PIN
    OpChangePin:
        call Crlf

        ;Ask for new PIN
        mov edx, OFFSET strNewPin
        call WriteString
        call ReadInt
        mov tempPinInput, eax ; Store the first entry safely in a variable

        ;Ask to confirm
        mov edx, OFFSET strConfirm
        call WriteString
        call ReadInt ; New entry in EAX

        ;compare eax with tempPinInput
        cmp eax, tempPinInput
        jne PinMismatch ; Jump if Not Equal

        ;Success: Overwrite systemPIN
        mov systemPIN, eax ; Update the systemPIN

        call Crlf
        mov edx, OFFSET strPinSuccess
        call WriteString
        call WaitMsg
        jmp MenuLoop

    PinMismatch:
        call Crlf
        mov edx, OFFSET strPinFail
        call WriteString
        call WaitMsg
        jmp MenuLoop

    ; ERROR HANDLERS
    InsufficientFunds:
        call Crlf
        mov edx, OFFSET strErrFunds
        call WriteString
        call WaitMsg
        jmp MenuLoop

    InputError:
        call Crlf
        mov edx, OFFSET strErrInput
        call WriteString
        call WaitMsg
        jmp MenuLoop

    ; LOGOUT / EXIT
    OpLogout:
        call Crlf
        mov edx, OFFSET strLogout
        call WriteString
        call WaitMsg
        ; Instead of exiting, we jump back to the very top (LoginLoop)
        ; This allows you to test if the new PIN actually works.
        jmp LoginLoop
main ENDP
END main