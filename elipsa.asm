
; zadanie 2 
; zmiana rozmiaru elipsy przy pomocy strzałek, kliknięcie spacji rysuje okrąg 160 x 160

dane1 segment

a db ? ; argv1 przez 2 (max 160)
b db ? ; argv2 przez 2 (max 100)
x dw ?
y dw ? ; x i y względem środka (99, 159)
kolor db ?

bladDanych db "Blad danych wejsciowych!", 10, 13, "$"

argv1 db 0, 0, 0
argv2 db 0, 0, 0

pierwszyKolor db 3

dane1 ends



code1 segment

start1:

; --------------------------------------------------- inicjowanie stosu

    mov ax, seg stos1 
	mov ss, ax 
	mov sp, offset wstos1 

; --------------------------------------------------- wczytanie argumentów z lini komend

    mov ax, seg dane1
    mov es, ax

    xor ch, ch 
    mov cl, byte ptr ds:[080h] ; w cx ilość znaków z lini komend

	mov di, 082h  ; przepisywanie kolejnych słów

    p7: ; pomijanie spacji oraz tabów przed argumentami
        mov al, byte ptr ds:[di]
        inc di
        dec cl
        cmp al, " "
        je p7
        cmp al, 9 ; tabulacja
        je p7
        cmp cl, 0
        je cosByloZle

    dec di
    inc cl
    push di
    xor bx, bx ; w bx będzie ilość cyfr argumentu

    p1: 
        mov al, byte ptr ds:[di] ; w al będą literki z argv
        inc di

        cmp al, " "
        je rodzielenieCiagDalszy ; znaleziono spacje czyli następne słowo
        cmp al, 9
        je rodzielenieCiagDalszy ; znaleziono tabulacje czyli następne słowo

        cmp al, "0"
        jl cosByloZle
        cmp al, "9"
        jg cosByloZle ; sprawdzanie czy cyfra

        inc bl 
        cmp bl, 4
        je cosByloZle ; sprawdzenie czy liczba 4+ cyfrowa
	loop p1 

    rodzielenieCiagDalszy:
    pop ax 
    dec cl
    push cx 
    push di
    mov di, ax

    xor ch, ch
    mov cl, bl 
    mov si, offset argv1 + 2
    sub si, bx 
    inc si

    przepisywanie1:
        mov al, byte ptr ds:[di] 
        sub al, "0"
        mov byte ptr es:[si], al ; przepisanie do zmiennej już jako 3 cyfry a nie literki w kolejności jak w liczbie
        inc di
        inc si
    loop przepisywanie1 

    pop di
    pop cx

    p77: ; pomijanie spacji oraz tabów pomiędzy argumentami
        mov al, byte ptr ds:[di]
        inc di
        dec cl
        cmp al, " "
        je p77 
        cmp al, 9
        je p77
        cmp cl, 0 
        je cosByloZle

    dec di
    inc cl

    xor bx, bx ; wszystko powyższe dla 2 argumentu
    push di

    p2: 
        mov al, byte ptr ds:[di] 
        inc di

        cmp al, " "
        je koniecDrugiegoSlowa 
        cmp al, 9
        je koniecDrugiegoSlowa
        cmp al, 13
        je koniecDrugiegoSlowa ; powrót karety (koniec argv)

        cmp al, "0"
        jl cosByloZle
        cmp al, "9"
        jg cosByloZle
        
        inc bl 
        cmp bl, 4
        je cosByloZle
	loop p2 

    koniecDrugiegoSlowa:
    dec cl
    pop di

    mov cx, bx 
    mov si, offset argv2 + 2
    sub si, bx 
    inc si

    przepisywanie2:
        mov al, byte ptr ds:[di] 
        sub al, "0"
        mov byte ptr es:[si], al
        inc di
        inc si
    loop przepisywanie2 

    p777: ; pętla sprawdzająca czy po argumentach były tylko spacje oraz tabulacje
        mov al, byte ptr ds:[di] 
        inc di 
        cmp al, " "
        je p777 
        cmp al, 9
        je p777 
        cmp al, 13 
        je wszystkoByloDobrze
        jmp cosByloZle

    wszystkoByloDobrze:

; --------------------------------------------------- incjowanie ds'a jako segment danych oraz es'a jako segment pamięci dla grafiki

    mov ax, seg dane1 
    mov ds, ax

    mov ax, 0a000h
    mov es, ax

; --------------------------------------------------- zamiana argumnetów na a i b

    mov si, offset argv1
    mov dl, 0
    call zamienNaPolOs 

    mov si, offset a 
    mov byte ptr ds:[si], al

    mov si, offset argv2
    mov dl, 1
    call zamienNaPolOs 

    mov si, offset b 
    mov byte ptr ds:[si], al

; --------------------------------------------------- rysowanie (liczy kolejno igreki dla x oraz iksy dla y i korzysta z jednego z dwóch wzorów)
    
    mov al, 13h 
    mov ah, 0 
    int 10h ; zmiana na tryb graficzny

    rysuj:

    mov al, byte ptr ds:[pierwszyKolor]
    mov byte ptr ds:[kolor], al ; resetowanie koloru pixeli

    call ustawSiOrazDi ; ustawia w celu wykorzystania wzoru 1 lub 2 zależnie od a < b (dla x będzie inny wzór niż dla y)

    xor ch, ch
    push si 
    mov si, offset a
    mov cl, byte ptr ds:[si] ; x odpowiada cx
    pop si

    cmp cx, 0
    je bezRysowania

    rysujacaPoX:
        call wybierzWzorDlaX

        push si 
        push di 
        
        mov si, offset x
        mov word ptr ds:[si], cx
        mov di, offset y
        call rysujCwiartki

        pop di 
        pop si 
    loop rysujacaPoX

    push si 

    xor ch, ch
    mov si, offset b
    mov cl, byte ptr ds:[si] ; y odpowiada cx

    mov si, offset kolor 
    mov al, 3
    mov byte ptr ds:[si], al 

    pop si

    cmp cx, 0
    je bezRysowania

    rysujacaPoY:
        call wybierzWzorDlaY

        push si 
        push di 

        mov si, offset y
        mov word ptr ds:[si], cx
        mov di, offset x
        call rysujCwiartki

        pop di 
        pop si 
    loop rysujacaPoY

    call ustawPierwszyKolor

    bezRysowania:

; --------------------------------------------------- obsługa klawiszy

    in al, 60h ; w al jest ostatnio wciesniety scan code z klawiatury

    cmp al, 80 
    je strzalkaDol

    cmp al, 72 
    je strzalkaGora

    cmp al, 75 
    je strzalkaLewo

    cmp al, 77 
    je strzalkaPrawo

    cmp al, 57
    je zrobKolo

    cmp al, 1 ; escape
    jne rysuj

    mov al, 3 
    mov ah, 0 
    int 10h ; powrót do trybu tekstowego

; --------------------------------------------------- funkcje

koniecProgramu: ; powrot do systemu
    mov ax, 4c00h
	int 21h 

wypisz: ; w dx musi być offset
    push ds
    push ax
    mov ax, seg dane1
    mov ds, ax
    xor ax, ax
	mov ah, 9 
	int 21h 
    pop ax
    pop ds
	ret 

cosByloZle: ; wypisuje błąd
    mov dx, offset bladDanych
    call wypisz
    jmp koniecProgramu

obliczPierwiastek: ; liczy pierwiastek (najmniejszymi kwadratami) z bx i zapisuje w ax
    push cx

    mov cx, 0ffffh
    mov ax, 0

    pp1:
        push ax 
        push bx

        mov bx, ax
        mul bl 
        pop bx

        cmp ax, bx 
        jge koniecPierwiastka

        pop ax 
        inc ax
    loop pp1

    koniecPierwiastka:
    pop ax
    pop cx 
    ret

zapalPunkt: ; zapala punkt (x, y) na wartość w zmiennej kolor
    push ax 
    push bx
    push si
    push di

    mov si, offset y
    mov ax, word ptr ds:[si] ; y
    add ax, 99d ; środek
    mov bx, 320d ; w lini tyle pixeli
    mul bx 

    mov si, offset x
    mov bx, word ptr ds:[si] ; x
    add bx, 159d ; środek
    add bx, ax ; w bx offset pixela

    mov si, offset kolor
    mov al, byte ptr ds:[si]
    mov byte ptr es:[bx], al ; zapalenie punktu na obecny kolor

    pop di
    pop si
    pop bx
    pop ax
    ret

rysujOdNowa: ; czyści ekran oraz rysuje elipse na nowo
    push ax 
    mov al, 3
    mov byte ptr ds:[pierwszyKolor], al
    pop ax
    push cx 
    mov cx, 0FA00h
    czysc:
        mov si, cx
        mov byte ptr es:[si], 0
    loop czysc
    pop cx
    jmp rysuj

zamienNaPolOs: ; w si offset słowa, wynik będzie w ax, w dl 0 dla a i 1 dla b
    add si, 2d

    xor ax, ax 
    mov al, byte ptr ds:[si] ; jedności
    push ax 

    mov bl, 10d 
    dec si 
    xor ax, ax 
    mov al, byte ptr ds:[si]
    mul bl ; dziesiątki
    push ax 

    mov bl, 100d 
    dec si 
    xor ax, ax 
    mov al, byte ptr ds:[si] ; setki
    mul bl 

    pop bx 
    add ax, bx
    pop bx 
    add ax, bx ; w ax są teraz średnice

    cmp dl, 0
    je sprawdzCzyDobreA
    jmp sprawdzCzyDobreB
    powrotPoSprawdzeniuPolosi:

    xor bh, bh
    mov bl, 2d 
    div bl 
    xor ah, ah ; dzielenie przez 2 aby mieć półosie
    ret

rysujCwiartki: ; rysuje 4 pukty symetryczne względem środka i zmienia kolor na następny
    mov word ptr ds:[di], ax
    call zapalPunkt ; IV ćwiartka 

    xor bh, bh
    neg ax
    inc ax
    mov word ptr ds:[di], ax 
    call zapalPunkt ; I ćwiartka 
   
    mov ax, cx 
    xor ah, ah
    neg ax
    inc ax
    mov word ptr ds:[si], ax
    call zapalPunkt ; II ćwiartka 
    
    mov ax, word ptr ds:[di] 
    neg ax
    inc ax
    mov word ptr ds:[di], ax
    call zapalPunkt ; III ćwiartka

    mov si, offset kolor 
    mov al, byte ptr ds:[si]
    inc al
    mov byte ptr ds:[si], al ; zmiana koloru na następny
    ret

policzPierwszymWzorem: ; (b * sqrt(a * a - x * x)) / a, może być b -> a oraz x -> y naraz 
    xor ah, ah 
    mov al, byte ptr ds:[si]
    xor bh, bh 
    mov bl, al 
    mul bl 
    push ax ; na stosie a ^ 2 lub b ^ 2

    xor ah, ah 
    mov al, cl
    xor bh, bh 
    mov bl, al 
    mul bl ; w ax x ^ 2 lub y ^ 2

    pop bx 
    sub bx, ax ; w bx to z czego będzie liczony pierwiastek
        
    call obliczPierwiastek ; wynik w ax
        
    mov bl, byte ptr ds:[di]
    mul bl ; ax *= b lub a
    mov bl, byte ptr ds:[si]
    div bl 
    xor ah, ah ; ax /= a lub b

    cmp dl, 0
    je powrotPoObliczeniuDlaX
    jmp powrotPoObliczeniuDlaY

policzDrugimWzorem: ; sqrt(b * b - (b * x / a) ^ 2), może być b -> a oraz x -> y naraz     
    xor ah, ah 
    mov al, byte ptr ds:[si]
    mul cl ; w ax b * x lub y

    xor bh, bh 
    mov bl, byte ptr ds:[di]
    div bl 
    xor ah, ah ; w ax /= a lub b

    mov bx, ax
    mul bx 
    push ax ; na stosie ax ^ 2

    xor ah, ah 
    xor bh, bh 
    mov al, byte ptr ds:[si]
    mov bl, al
    mul bl ; w ax b ^ 2 lub a ^ 2

    mov bx, ax 
    pop ax
    sub bx, ax ; w bx to z czego będzie liczony pierwiastek
   
    call obliczPierwiastek ; wynik w ax

    cmp dl, 0
    je powrotPoObliczeniuDlaX
    jmp powrotPoObliczeniuDlaY

ustawSiOrazDi: ; odpowiednio dla wzorów na elipse
    mov si, offset a 
    mov di, offset b 
    mov al, byte ptr ds:[si]
    mov bl, byte ptr ds:[di]

    cmp al, bl 
    jl zmienSiNaDi

    powrotPoZmianieSiOrazDi:
    ret

wybierzWzorDlaX: ; liczy y dla x używając odpowiedniego wzoru
    push si 
    push di
    mov si, offset a 
    mov di, offset b 
    mov al, byte ptr ds:[si]
    mov bl, byte ptr ds:[di]
    pop di 
    pop si
    mov dl, 0

    cmp al, bl 
    jg policzPierwszymWzorem
    jmp policzDrugimWzorem 

    powrotPoObliczeniuDlaX:
    ret

wybierzWzorDlaY: ; liczy x dla y używając odpowiedniego wzoru
    push si 
    push di
    mov si, offset a 
    mov di, offset b 
    mov al, byte ptr ds:[si]
    mov bl, byte ptr ds:[di]
    pop di 
    pop si
    mov dl, 1

    cmp al, bl 
    jl policzPierwszymWzorem
    jmp policzDrugimWzorem 

    powrotPoObliczeniuDlaY:
    ret

ustawPierwszyKolor: ; ustawia kolor na jeden większy modulo 250
    cmp byte ptr ds:[pierwszyKolor], 250
    je zmienNaPoczatkowy

    inc byte ptr ds:[pierwszyKolor]

    powrotPoKolorze:
    ret

zrobKolo: ; rysuje okrąg 160 x 160
    mov byte ptr ds:[a], 80d 
    mov byte ptr ds:[b], 80d 
    jmp rysujOdNowa

; --------------------------------------------------- ify

zmienSiNaDi:
    mov si, offset b 
    mov di, offset a 
    jmp powrotPoZmianieSiOrazDi

strzalkaDol:
    mov si, offset b 
    mov bl, byte ptr ds:[si]
    cmp bl, 0
    jne zmniejszB
    jmp rysuj

zmniejszB:
    dec bl 
    mov byte ptr ds:[si], bl
    jmp rysujOdNowa

strzalkaGora:
    mov si, offset b 
    mov bl, byte ptr ds:[si]
    cmp bl, 100
    jne zwiekszB
    jmp rysuj

zwiekszB:
    inc bl 
    mov byte ptr ds:[si], bl
    jmp rysujOdNowa

strzalkaLewo:
    mov si, offset a 
    mov bl, byte ptr ds:[si]
    cmp bl, 0
    jne zmniejszA
    jmp rysuj

zmniejszA:
    dec bl 
    mov byte ptr ds:[si], bl
    jmp rysujOdNowa

strzalkaPrawo:
    mov si, offset a
    mov bl, byte ptr ds:[si]
    cmp bl, 160
    jne zwiekszA
    jmp rysuj

zwiekszA:
    inc bl 
    mov byte ptr ds:[si], bl
    jmp rysujOdNowa

zmienNaPoczatkowy:
    push ax
    mov al, 3
    mov byte ptr ds:[pierwszyKolor], al
    pop ax 
    jmp powrotPoKolorze

sprawdzCzyDobreA:
    cmp ax, 320 
    jg cosByloZle
    jmp powrotPoSprawdzeniuPolosi

sprawdzCzyDobreB:
    cmp ax, 200 
    jg cosByloZle
    jmp powrotPoSprawdzeniuPolosi

; --------------------------------------------------- koniec kodu

code1 ends



stos1 segment stack

       dw 300 dup(?)

wstos1 dw ? 

stos1 ends



end start1
