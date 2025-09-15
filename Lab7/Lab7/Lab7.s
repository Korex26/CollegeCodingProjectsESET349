        ; result indicated by R12 (len : fail, other : 0-index of target)

        AREA lab7, CODE, READONLY          ; declare code area
words   DCD 0x01, 0x02, 0x04, 0x06, 0x08, 0x0b, 0x0f, 0x11 ; array of words to search within
len     EQU 0x07                           ; set constant 'len' to 7, representing the array length
target  EQU 0x02                           ; set constant 'target' to 8, the value we are searching for
        EXPORT __main                      ; export '_main' as the entry point of the code

__main   PROC                              ; define the main procedure

        ; perform binary search
        LDR R0, =words                     ; load base address of 'words' array into register R0
        MOV R1, #0                         ; initialize left index to 0 in R1
        MOV R2, #len                       ; initialize right index to the array length
        SUB R2, R2, #0x01                  ; adjust right index to the last element index

repeat  CMP R1, R2                         ; compare left and right indices
        BGT fail                           ; if left index > right index, jump to 'fail' as search failed

        ; Calculate midpoint
        ADD R3, R1, R2                     ; add left and right indices
        ASR R3, R3, #1                     ; divide by 2 to find the midpoint (middle index)

        ; Load middle element into R12
        LDR R4, [R0, R3, LSL #2]           ; calculate array offset for middle index and load middle element into R4

        ; Compare middle element with target
        CMP R4, #target                    ; compare middle element with target
        BEQ found                          ; if middle element == target, jump to 'found'

        ; if middle element < target, search right half
        BLT right                          ; branch to 'right' to search in the right half

        ; if middle element > target, search left half
left    SUB R2, R3, #1                     ; update right index to mid - 1
        B repeat                           ; repeat the search process with updated indices

right   ADD R1, R3, #1                     ; update left index to mid + 1
        B repeat                           ; repeat the search process with updated indices

fail    MOV R12, #len                      ; set R12 to len to indicate failure
        B end                              ; jump to end

found   MOV R12, R3                        ; move the middle index to R12 as result

end     ; End of the main procedure
        BX LR                              ; return from procedure
