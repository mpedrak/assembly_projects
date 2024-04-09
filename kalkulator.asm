
; zadanie 1

dane1 segment

bufor db 250, ?, 250 dup("$")
nowaLinia db 10, 13, "$"
bladDanych db "Blad danych wejsciowych!$"
ujemna db "minus $"
spacja db " $"
wprowadz db "Wprowadz slowny opis dzialania: $"
wynikiemJest db "Wynikiem jest: $"

zero db "5zero$0"
jeden db "6jeden$1"
dwa db "4dwa$2"
trzy db "5trzy$3"
cztery db "7cztery$4"
piec db "5piec$5"
szesc db "6szesc$6"
siedem db "7siedem$7"
osiem db "6osiem$8"
dziewiec db "9dziewiec$9"
ogranicznikCyfr db "0$"

dziesiec db "9dziesiec$0"
jedynascie db ";jedenascie$1"
dwanascie db ":dwanascie$2"
trzynascie db ";trzynascie$3"
czternascie db "<czternascie$4"
pietnascie db ";pietnascie$5"
szesnascie db ";szesnascie$6"
siedemnascie db "=siedemnascie$7"
osiemnascie db "<osiemnascie$8"
dziewietanscie db "?dziewietnascie$9"
ogranicznikNascie db "0$"

dwadziescia db "<dwadziescia$2"
trzydziesci db "<trzydziesci$3"
czterdziesci db "=czterdziesci$4"
piecdziesiat db "=piecdziesiat$5"
szescdziesiat db "<szesciesiat$6"
siedemdziesiat db "?siedemdziesiat$7"
osiemdziesiat db ">osiemdziesiat$8"
dziewiecdziesiat db "Adziewiecdziesiąt$9"
ogranicznikDziesiat db "0$"

plus db "5plus$+"
minus db "6minus$-"
razy db "5razy$*"
ogranicznikDzialan db "0$"

cyfraPierwsza db 100 dup("$")
dzialanie db 100 dup("$")
cyfraDruga db 100 dup("$")
wynik db 3 dup("$")

dane1 ends



code1 segment

start1:

; --------------------------------------------------- inicjowanie stosu

    mov ax, seg stos1 
	mov ss, ax 
	mov sp, offset wstos1 

; --------------------------------------------------- wypisanie pierwszej lini

    mov dx, offset wprowadz
    call wypisz

; --------------------------------------------------- wczytanie i rozdzielanie tekstu

    mov ax, seg dane1
	mov ds, ax
	mov dx, offset bufor
	mov ah, 0ah 
	int 21h ; wczytanie tekstu do bufora

    mov bp, offset bufor + 1 
	mov cl, byte ptr ds:[bp] ; umieszczenie w cl ilości wczytanych znaków

	mov si, offset cyfraPierwsza
	mov di, offset bufor + 2 ; przepisywanie kolejnych słów

    p1: 
        mov al, byte ptr ds:[di] ; w al będą literki z bufora
        inc di

        cmp al, " "
        je rozdzielanieDrugie ; znaleziono spacje czyli następne słowo

        mov byte ptr ds:[si], al
        inc si 
	loop p1 

    rozdzielanieDrugie:  

    dec cl ; bo skoczyliśmy ze środka pętli
	mov si, offset dzialanie

    p2:
        mov al, byte ptr ds:[di] 
        inc di

        cmp al, " "
        je rozdzielanieTrzecie

        mov byte ptr ds:[si], al
        inc si 
	loop p2 

    rozdzielanieTrzecie: 

    dec cl
	mov si, offset cyfraDruga

    p3:
        mov al, byte ptr ds:[di] 
        inc di

        cmp al, " "
        je cosByloZle ; niepoprawne dane wejściowe

        mov byte ptr ds:[si], al
        inc si 
	loop p3 

; --------------------------------------------------- zamiana działania na znak +, -, * i wstawienie go do pierwszego bajtu
   
    mov di, offset dzialanie
    mov dl, 0 ; przygotowanie 'argumentów' dla procedury
    mov si, offset plus 
    jmp zamienNaSymbol

    koniecZamianyDzialania: ; wynik procedury znajduje się w al
    mov si, offset dzialanie
    mov byte ptr ds:[si], al

; --------------------------------------------------- zamiana słów na cyfry, i wstawienie ich do pierwszych bajtów

    mov di, offset cyfraPierwsza
    mov dl, 1
    mov si, offset zero 
    jmp zamienNaSymbol

    koniecZamianyPierwszejCyfry: 
    mov si, offset cyfraPierwsza
    mov byte ptr ds:[si], al

    mov di, offset cyfraDruga
    mov dl, 2
    mov si, offset zero 
    jmp zamienNaSymbol

    koniecZamianyDrugiejCyfry: 
    mov si, offset cyfraDruga
    mov byte ptr ds:[si], al

; --------------------------------------------------- obliczanie wyniku

    mov si, offset cyfraPierwsza
    mov al, byte ptr ds:[si]
    sub al, "0" ; w al będzie pierwsza cyfra

    mov si, offset cyfraDruga
    mov bl, byte ptr ds:[si]
    sub bl, "0" ; w bl będzie druga cyfra

    mov si, offset dzialanie
    mov cl, byte ptr ds:[si] ; w cl będzie działanie

    cmp cl, "*"
    je przemnoz

    cmp cl, "+"
    je dodaj

    cmp cl, "-"
    je odejmij

    powrotPoWykonaniuDzialania:

; --------------------------------------------------- obługiwanie wyników ujemnych

    mov dx, offset nowaLinia
    call wypisz
    mov dx, offset wynikiemJest ; rozpoczęcie wypisywania drugiej lini
    call wypisz 
    
    cmp al, 0
    jl ujemnaLiczba ; jeśli liczba ujemna do wypisuje minus oraz zmienia jej znak
    powrotPoDodaniuZnaku:

; --------------------------------------------------- obługiwanie wyników dwucyfrowych

    mov bl, 0ah
    mov ah, 0
    mov bh, 0
    div bl ; dzielenie całkowite przez 10, w al będzie wynik 'diva' a w ah wynik 'modulo'

    add al, "0"
    mov si, offset wynik
	mov byte ptr ds:[si], al

    add ah, "0"
    mov si, offset wynik + 1
	mov byte ptr ds:[si], ah

; --------------------------------------------------- wypisywanie
 
    mov si, offset wynik
    mov al, byte ptr ds:[si]
    sub al, "0"
    cmp al, 0
    je jednocyfrowa

    cmp al, 1
    je nastki 

    jmp dziesiatki

    poWypisaniuDziesiatek:
    mov si, offset wynik + 1
    mov al, byte ptr ds:[si]
    sub al, "0"

    mov dx, offset spacja
    call wypisz
    
    cmp al, 0
    jne jednocyfrowa ; jęśli wypisaliśmy 'dziesiąt' i cyfra jedności jest różna od 0
    
    poWypisaniuJednosci:
    mov dx, offset nowaLinia
    call wypisz 

; --------------------------------------------------- funkcje

koniecProgramu: ; powrot do systemu
    mov ax, 4c00h
	int 21h 

wypisz: ; w dx musi być offset
    push ax
	mov ax, seg dane1
	mov ds, ax
	mov ah, 9 
	int 21h 
    pop ax
	ret 

cosByloZle: ; wypisuje błąd
    mov dx, offset nowaLinia
    call wypisz
    mov dx, offset bladDanych
    call wypisz
    mov dx, offset nowaLinia
    call wypisz
    jmp koniecProgramu

zamienNaSymbol: ; w di musi być offset słowa, w si offset pierwszego symbolu, w dl numer słowa (działanie - 0, pierwsza cyfra - 1, druga cyfra - 2)
    pp1:
        push di ; zachowujemy wkaźniki na początki sprawdzanych słów
        push si 
        mov cl, byte ptr ds:[si]
        sub cl, "0" ; w cl mamy długość 'symbolu' włącznie z $
        inc si 

        cmp cl, 0 ; skończyły się symbole
        je cosByloZle

        ppp1:
            mov bl, byte ptr ds:[si]
            mov al, byte ptr ds:[di]
            inc di 
            inc si

            cmp al, bl ; jeśli literki są różne
            jne nastepnySymbol
        loop ppp1

        cmp al, "$" ; jeśli słowo też się skończyło to znaleziono własciwy symbol, jęsli nie to idzie na następny symbol
        je toTenSymbol

    nastepnySymbol:
        pop si
        pop di
        mov al, byte ptr ds:[si]
        sub al, "0"
        xor ah, ah ; w ax jest ilość znaków słowa o które trzeba przesunąć stare si, plus jeszcze potem o 2 aby być na początku następnego
        add si, ax
        add si, 2
        jmp pp1

zamienNaSlowo: ; offset cyfry musi być w di, w si sumer pierwszego słowa, w dl numer cyfry (dziesiątki - 1, jedności - 2)

    mov al, byte ptr ds:[di] ; w al będzie cyfra dla której chcemy znaleźć słowo
    pp2:
        push si ; zapamiętujemy si dla przypadku jeśli to będzie szukane słowo oraz al w którym mamy cyfre
        push ax 
        mov al, byte ptr ds:[si] 
        sub al, "0"
        cmp al, 0 ; skończyły się słowa
        je koniecProgramu

        xor ah, ah
        add si, ax ; używamy ax do przesunięcia si
        inc si 
        mov bl, byte ptr ds:[si] ; w bl będzie symbol przeszukiwanego słowa
        pop ax
        
        cmp al, bl
        jne nastepneSlowo

        jmp toToSlowo

    nastepneSlowo:
        pop bp ; żeby nie zostawiać na stosie
        inc si ; przesuwamy się na następne słowo
        jmp pp2

; --------------------------------------------------- ify
 
przemnoz:
    mul bl 
    jmp powrotPoWykonaniuDzialania

dodaj:
    add al, bl 
    jmp powrotPoWykonaniuDzialania

odejmij:
    sub al, bl 
    jmp powrotPoWykonaniuDzialania

ujemnaLiczba:
    mov bl, al
    xor al, al
    sub al, bl ; zmiana znaku al na przeciwny
    mov dx, offset ujemna ; wypisanie 'minus'
    call wypisz
    jmp powrotPoDodaniuZnaku

toTenSymbol:
    mov al, byte ptr ds:[si] ; w al znaleziony symbol
    pop si
    pop di
    cmp dl, 0
    je koniecZamianyDzialania
    cmp dl, 1
    je koniecZamianyPierwszejCyfry
    cmp dl, 2
    je koniecZamianyDrugiejCyfry

toToSlowo:
    pop si 
    inc si
    push dx
    mov dx, si 
    call wypisz
    pop dx
    cmp dl, 1
    je poWypisaniuDziesiatek
    cmp dl, 2
    je poWypisaniuJednosci
  
jednocyfrowa:
    mov dl, 2
    mov si, offset zero 
    mov di, offset wynik + 1
    jmp zamienNaSlowo

nastki:
    mov dl, 2
    mov si, offset dziesiec 
    mov di, offset wynik + 1
    jmp zamienNaSlowo

dziesiatki:
    mov dl, 1
    mov si, offset dwadziescia 
    mov di, offset wynik
    jmp zamienNaSlowo

; --------------------------------------------------- koniec kodu

code1 ends



stos1 segment stack

       dw 300 dup(?)

wstos1 dw ? 

stos1 ends



end start1

