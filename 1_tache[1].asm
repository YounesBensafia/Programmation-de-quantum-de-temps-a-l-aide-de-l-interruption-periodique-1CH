;BENSAFIA YOUNES 212132032981                   ;GROUPE 4
;BARAGH YASSER ABDELJALIL 202032021716          ;GROUPE 4

; DEBUT DU DATA SEGMENT (DS)
data SEGMENT
    msg db " 1 sec ecoulee...... ", "$" ; MESSAGE 1
    msg2 db "****Debut du quantum de temps logiciel****", "$" ; MESSAGE 2
    dert db "Deroutement fait....",10,10,13,"$" ; MESSAGE 3
    compt dw 18 ; COMPTEUR POUR LES 1 SECONDES ECOULEES
    retLine db 10,13,"$" ; POUR LE RETOUR A LA LIGNE
data ENDS
; LA FIN DU DATA SEGMENT (DS)
    
; DEBUT STACK SEGMENT (SS)
maPile SEGMENT STACK
    dw 256 dup(?)
    tos label word
maPile ENDS
; FIN STACK SEGMENT (SS)
   
; DEBUT CODE SEGMENT (CS)    
code SEGMENT
    assume CS:code, DS: data, SS: maPile ;ASSUME
    ; LA FONCTION QUI FAIT LE DEROUTEMENT GRACE L'FONCTION AH=25h DU INT 21H
    derout_1CH PROC NEAR
    ; 25h/21h installer un nouveau vecteur ; ES/ AL : numero du vect a installer ; DS:DX: les adresses cs et ip de la nouvelle routine d it
    push ds ;SAUVGARDER LE DS DANS LA PILE AVANT D'INSTALLER LE VECTEUR
    mov ax , seg new
    mov ds , ax   ; CSnew DANS DS
    mov dx , offset new ; IPnew DANS DX
    mov ax , 251CH ;MOV AH,25H; MOV AL,1CH;
    int 21H
    pop ds 
    ret
    derout_1CH ENDP
    ; PROCEDURE AFFICHER QUI VA AFFICHER TOUS LES MESSAGES DE CE PROGRAMME
    
affiche PROC NEAR
mov bp,sp; BP REJOINT SP 
mov dx,[bp+2]; [BP + 2] VA CONTENIR TOUJOURS L OFFSET DU MESSAGE QU ON AFFICHER 
mov ah , 09h; INT POUR AFFICHER UNE CHAINE DE CARACTERES (DX; OFFSET DU PREMIER CARACTERE DE LA CHAINE
int 21h
ret
affiche endp

; DEROUTEMENT DU 1CH AVEC NEW
    new: 
    dec compt ; DEC POUR 1 SEC
    jnz fin   ; IL VA ATTENDRE UNE SECONDE POUR AFFICHER 
    push offset msg ; MESSAGE 1
    call NEAR PTR affiche 
    pop bx ; POUR QU ON AURA PAS DE PROBLEME CONSERNANT LE IRET ET LA PILE
    mov compt, 18 ;UNE AUTRE SECONDE
    fin: iret ; PSW/CS/IP
; PROGRAMME COMMENCE ICI >>>>>
start: mov ax , data
       mov ds , ax
       mov ax , maPile
       mov ss , ax
       lea sp, tos
       
       call NEAR PTR derout_1CH 
       push offset dert
       call near ptr affiche
boucle:                                                                   
         push offset msg2                                             
         call near ptr affiche
         ;DELAI DU TEMPS 
         mov cx, 02Bfh        
         boucle_externe : mov si, 0cfffh                               
              boucle_interne :            dec si                          
                                          jnz boucle_interne
                                               
         loop boucle_externe
         
         push offset retLine ; RETOUR A LA LIGNE 10,13                                                
         call near ptr affiche ;AFFICHER LE RETOUR A LA LIGNE

jmp boucle ;POUR QUE IL VA TOUJOURS AFFICHER LE MESSAGE2
code ENDS
; FIN DU CODE SEGEMENT
END start