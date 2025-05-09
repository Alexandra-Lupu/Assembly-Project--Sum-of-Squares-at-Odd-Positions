.model small
.stack 100h
.data
    msg1 db 'Introduceti elementele vectorului (10 max, doar cifre). Apasati Enter pentru a termina:', 0Ah, 0Dh, '$'
    msg2 db 'Suma patratelor elementelor de pe pozitii impare este:', 0Ah, 0Dh, '$'
    msg3 db 'Programul s-a terminat.', 0Ah, 0Dh, '$'
    vec db 10 dup(0)    ; Vectorul pentru stocare, initial tot este zero
    vec_size db 0       ; Lungimea vectorului (numărul de elemente citite)

.code
start:
    mov ax, @data
    mov ds, ax

    ; Afisez 'cerinta' pentru utilizator
    lea dx, msg1        ; Spune exact sistemului de unde din memorie afiseaza mesajul
    mov ah, 09h
    int 21h

    ; Se citesc elementele vectorului de la tastatura si se stocheaza in vector
    lea di, vec            ; di pointeaza la inceputul vectorului
    xor cx, cx             ; cx=0 (numara elementele citite)
citire:
    mov ah, 01h            ; Citeste un caracter
    int 21h
    cmp al, 0Dh            ; Verifica daca utilizatorul a apasat Enter
je gata_citire             ; Daca da, inseamna ca s-au citit elementele, deci iese din bucla
    sub al, '0'            ; Converteste din ASCII in valoare numerica 
    mov [di], al           ; Stocheaza valoarea in vector
    inc di                 ; Treci la urmatoarea pozitie din vector
    inc cx                 ; Incrementeaza numarul de elemente total al vectorului
    cmp cx, 10             ; Compara numarul de elemente curent cu 10 ca sa stie daca mai sunt elemente de introdus sau nu
jl citire                  ; Daca cx nu a ajuns la 10, citeste urmatorul element, reia bucla de la inceput

gata_citire:
    mov vec_size, cl        ; Salveaza numarul de elemente total citite

;In acest moment, vectorul contine elementele NUMERICE (transformate din codul ASCII), iar cx este nr de elemente din vector

    xor bx, bx             ; Se initializeaza suma, bx=0 (suma finală va fi stocată în bx)
    lea si, vec            ; si pointeaza la inceputul vectorului
    xor di, di             ; di este indexul curent în vector, la inceput zero

calc_suma:
    mov al, vec_size       ; vec_size este `db`, deci un octet
    cmp di, ax             ; Verifica daca indexul a depasit lungimea (di>lungime => ja)
ja afisare_suma            ; Daca da, sare la afisarea rezultatului

    test di, 1             ; Testeaza daca di (index) este impar
jz urm_element             ; Daca este par, trece la urmatorul element

    ; Calculeaza patratul elementului de pe pozitia curenta
    mov al, [si]           ; AL = valoarea curenta din vector
    mov ah, 0              ; Extinde valoarea in ax, al este pe un singur octet, pun pe doi practic acelasi numar
    imul ax                ; ax=ax*ax 
    add bx, ax             ; Adaug patratul la suma 

urm_element:
    inc di                 ; Incrementez indexul (trec la urmatoarea pozitie)
    inc si                 ; Trec la urmatorul element din vector
    jmp calc_suma          ; Reia ciclul
afisare_suma:
    push ds                ; Salvăm DS pe stivă
    lea dx, msg2           ; Afișam mesajul introductiv
    mov ah, 09h
    int 21h

    ; Convertire suma în ASCII și afisare
    mov ax, bx             ; ax = suma (bx conține suma calculată)
    xor cx, cx             ; cx = 0 (va conta câte cifre avem)
    mov bx, 10             ; Baza 10 (pentru divizare)

convert:
    xor dx, dx             ; dx = 0 pentru div
    div bx                 ; Împărțim ax la 10 -> ax = ax / 10, dx = rest
    add dl, '0'            ; Convertim cifra în ASCII
    push dx                ; Salvăm cifra pe stivă
    inc cx                 ; Incrementăm numărul de cifre
    cmp ax, 0              ; Verificăm dacă mai avem cifre de convertit
    jne convert

afisare_cifre:
    pop dx                 ; Scoatem pe rând cifrele din stivă
    mov ah, 02h
    mov dl, dl             ; dl conține cifra ASCII         
    int 21h                ; Afișăm
    loop afisare_cifre

    ; Linie nouă
    mov ah, 02h
    mov dl, 0Dh            ; CR (Carriage Return)
    int 21h
    mov dl, 0Ah            ; LF (Line Feed)
    int 21h

    lea dx, msg3           ; Mesaj de finalizare
    mov ah, 09h
    int 21h

    pop ds                 ; Restaurăm DS din stivă
    mov ah, 4Ch            ; Terminare program
end start
