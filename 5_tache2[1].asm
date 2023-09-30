;BENSAFIA YOUNES 212132032981                   ;GROUPE 4
;BARAGH YASSER ABDELJALIL 202032021716          ;GROUPE 4


;DATA SEGMENT 
data segment                                                         
    dert db "Deroutement fait....",10,10,13,"$"                      
    tache_p1 db "Tache $"                                            
    tache_p2 db " est en cours d'execution",10,13,"$"                 
    numTache db "1$" ; variable pour changer le msg                  
    compt dw 91 ; compteur de boucle pour afficher un msg chaque 5sec
    retLine db 10,13,"$"; LE RETOUR A LA LIGNE   
    min dw 60 ; COMPTEUR POUR LES 5 MIN                                                      
data ends                                                            

;STACK SEGMENT
maPile segment stack   
    dw 128 dup(?)      
    tos label word     
maPile ends            

;CODE SEGMENT
code SEGMENT                                                                                         
    assume CS:code, DS: data, SS: maPile                                                               
                                                                                                     
      ;LA FONCTION QUI FAIT LE DEROUTEMENT GRACE L'FONCTION AH=25h DU INT 21H
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

    ;FONCTION D'AFFICHAGE DE TOUS LES MESSAGES DU PROGRAMME                                                                                               
affiche PROC NEAR                                                                                                                                                         
    mov bp,sp                                                                                      
    mov dx,[bp+2]                                                                                  
    mov ah , 09h                                                                                   
    int 21h                                                                                        
    ret                                                                                           
affiche endp                                                                                    

 ;PROCEDURES POUR AFFICHER TOUS LES MESSAGES DES TACHES // ELLE VA JUSTE CHANGER LES VALEURS DES TACHES   
 afficheTache PROC NEAR                                    
            cmp numTache,'6'                                                                                  
            jne debut                                              
            mov numTache,'1'                                       
            
            push offset retLine                                    
            call near ptr affiche                                  
            pop bx                                                 
                                                                   
            debut:
                ;AFFICHAGE MESSAGE 2            
                push offset tache_p1                                   
                call near ptr affiche                                  
                pop bx                                                 
                
                ;CHANGEMENT DES VALEURS 1-->2-->3-->4-->5                
                push offset numTache                                               
                call near ptr affiche                                          
                pop bx                                                 
                inc numTache                                          
                
                ;AFFICHAGE MESSAGE 3                
                push offset tache_p2                                                    
                call near ptr affiche                                                                                                      
                pop bx                                                                                                                                      
                ret                                                 
    afficheTache endp                                          

                                                                                                     
; PROCEDURE POUR AFFICHER UNE SPECIFIQUE TACHE                                                       
        new:                                                                  
        dec compt                                                               
        jnz fin ; Si compt n'est pas egal,zero, saute au fin                   
                                                                               
        call NEAR PTR afficheTache ; sinon fait appelle la procedure affiche
        dec min ;POUR LES 5 MINUTES
        jz exit                                                                
                                                                               
        mov compt , 91 ; Reinitialise la variable compt 91  (5s)                         
        fin: iret    
;DEBUT DU PROGRAMME>>>>>>>       
start:                                                                         
       mov ax , data                                                           
       mov ds , ax                                                             
       mov ax , maPile                                                                               
       mov ss , ax                                                                                   
       lea sp, tos                                                                                               
                                                                                                                                                                                                                              
       call NEAR PTR derout_1CH ; Appelle la proc?dure derout_1CH pour installer un nouveau vecteur d'interruption  
                                                                                                                          
       push offset dert                                                                              
       call near ptr affiche                                                                         
       pop bx                                                                                        
                                                                                                                                                                                                                       
    boucle1:jmp boucle1  ; Saute ? boucle pour boucler ind?finiment                                                                                 

exit: mov ax,4c00h
      int 21h                                                                                        
code ENDS                                                                                            
END start
; FIN DU PROGRAMME<<<<<<< 