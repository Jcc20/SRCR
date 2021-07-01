%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Trabalho individual de SRCR

%--------------------------------- - - - - - - - - - -  -  -  -  -   -

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).

% Carreira,id,gid,latitude,longitude,Estado de Conservacao,Tipo de Abrigo,Abrigo com Publicidade,Operadora,Codigo de Rua,Nome da Rua,Freguesia
:- dynamic paragem/12.

% ((Carreira,id,gid,Operadora,Tipo de Abrigo,Abrigo com Publicidade), (Carreira,idAdjacente,gidAdjacente,Operadora,Tipo de Abrigo,Abrigo com Publicidade))
:- dynamic arco/2.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -

:- include('C:/Users/Zezoca/Desktop/Uni/SRCR/TPI/SRCR/BaseConhecimentoAdjDuplosCompletos.pl').


%arrebenta
sol(S,F,V,P):-findall((P), zefAdj(S,F,V,P), L),
        print(L).


%Encontra caminho original , em profundidade,versão inicial, a da 1ª implementação da base de conhecimento
zefG(Start, Finish, Path,N):-
     paragem(_,_,Finish,_,_,_,_,_,_,_,_,_),  
     zef(Start, Finish, [Start], Path),
     length(Path, N).
     

zef(Gid, Gid, _, [Gid]).                     
zef(Start, Finish, Visited, [Start | Path]) :-
     paragem(C,I,Start,_,_,_,_,_,_,_,_,_),
     succ(I,T),
     paragem(C,T,X,_,_,_,_,_,_,_,_,_),
     \+(memberchk(X, Visited)),
     zef(X, Finish, [X | Visited], Path).

%Profundidade , não informada, com ajdacências
zefAdj2(Start, Finish, Path,N):-
     arco((_,_,Finish,_,_,_),(_,_,_,_,_,_)),
     zefa2(Start, Finish, [Start], Path),
     length(Path, N).
     

zefa2(Gid, Gid, _, [Gid]).                     
zefa2(Start, Finish, Visited, [Start | Path]) :-
     arco((_,_,Start,_,_,_),(_,_,X,_,_,_)),
     \+(memberchk(X, Visited)),
     zefa2(X, Finish, [X | Visited], Path).


%Pesquisa informada, em que verifica as carreiras comuns
zefAdj(Start, Finish, Path,N):-
	arco((_,_,Finish,_,_,_),(_,_,_,_,_,_)),
     (isoladaG(Start,Finish),print("Carreira Isolada");
	zefa(Start, Finish, [Start], Path),
	length(Path, N)).

isoladaG(Start,Finish):-
     isolada(Finish,C),
     !,
	\+arco((C,_,Start,_,_,_),_).

isolada(Finish,C):-
	arco((C,_,Finish,_,_,_),_),
	findall(B,arco((C,_,B,_,_,_),_),L),
	sort(L,P),
	length(P,N),
	succ(N,T),
	aux(C,1,T).
   
aux(_,I,I).                     
aux(C,I,N):-
	arco((C,I,X,_,_,_),_),
	findall(S,arco((S,_,X,_,_,_),_),L),
	sort(L,P),
	length(P,1),
	succ(I,T),
	aux(C,T,N).     

zefa(Gid, Gid,_, [Gid]).  
zefa(Gid, Gid,_, _).                     
zefa(Start, Finish, Visited, [Start | Path]) :-
	(comuns(Start,Finish,Path),
	zefa(Finish, Finish, Visited, Path));
	(arco((_,_,Start,_,_,_),(_,_,X,_,_,_)),
	\+(memberchk(X, Visited)),
	zefa(X, Finish, [X | Visited], Path)).

comuns(Ini,Fim,Cam):-    
	comunsL(Ini,Fim,[C|_]),
	arco((C,A,Ini,_,_,_),_),
	arco((C,B,Fim,_,_,_),_),
	cam(Ini,Fim,C,A,B,[Ini],[_|Cam]).

sub(X,Y):-
     Y is X-1.

cam(Gid, Gid, _, _, _, _, [Gid]).                     
cam(Start, Finish, C, A, B, Visited, [Start | Path]) :-
	arco((C,I,Start,_,_,_),_),
	(B>A -> succ(I,T) ; sub(I,T)),
     arco((C,T,X,_,_,_),_),
	\+(memberchk(X, Visited)),
	cam(X, Finish, C, A, B, [X | Visited], Path).

comunsL(Ini,Fim,CarrCom):-
	findall(CI,arco((CI,_,Ini,_,_,_),_),CarrI),
	sort(CarrI,PI),
	findall(CF,arco((CF,_,Fim,_,_,_),_),CarrF),
	sort(CarrF,PF),
	intersection(PI,PF, CarrCom),
	\+length(CarrCom,0).

%Q2Selecionar apenas algumas das operadoras de transporte para um determinado percurso;versão inicial, a da 1ª implementação da base de conhecimento
zeOperadoraGlobal(Start, Finish, Visited, Operadoras, Path):-
     paragem(_,_,Finish,_,_,_,_,_,OPF,_,_,_),
     member(OPF, Operadoras),
     zeOperadora(Start, Finish, Visited, Operadoras, Path).

zeOperadora(Gid, Gid, _, _,[Gid]).                      
zeOperadora(Start, Finish, Visited, Operadoras, [Start | Path]) :-   
     paragem(C,I,Start,_,_,_,_,_,OPS,_,_,_),
     member(OPS, Operadoras),   
     succ(I,T),
     paragem(C,T,X,_,_,_,_,_,OPN,_,_,_),
     member(OPN, Operadoras),   
     not(member(X, Visited)),
     zeOperadora(X, Finish, [X | Visited], Operadoras, Path).



%Q2Selecionar apenas algumas das operadoras de transporte para um determinado percurso,versao com comuns
query2G(Start, Finish, Operadoras, Path,N):-
     arco((_,_,Finish,OPF,_,_),(_,_,_,_,_,_)),
     memberchk(OPF, Operadoras),   
     (isoladaG(Start,Finish),print("Carreira Isolada");
     query2(Start, Finish, Operadoras,[Start], Path),
     length(Path, N)).   

query2(Gid, Gid,_, _, [Gid]).  
query2(Gid, Gid,_, _, _).                     
query2(Start, Finish, Operadoras, Visited, [Start | Path]) :-
     (comunsQ2(Start,Finish,Operadoras,Path),
     query2(Finish, Finish, Operadoras, Visited, Path));
     (arco((_,_,Start,OPF,_,_),(_,_,X,_,_,_)),
     memberchk(OPF, Operadoras),   
     \+(memberchk(X, Visited)),
     query2(X, Finish, Operadoras, [X | Visited], Path)).

comunsQ2(Ini,Fim,Operadoras,Cam):-    
     comunsLQ2(Ini,Fim,Operadoras,[C|_]),
     arco((C,A,Ini,OPF,_,_),_),
     memberchk(OPF, Operadoras),   
     arco((C,B,Fim,OP,_,_),_),
     memberchk(OP, Operadoras),   
     camQ2(Ini,Fim,C,A,B,Operadoras,[Ini],[_|Cam]).

camQ2(Gid, Gid, _, _, _, _, _, [Gid]).                     
camQ2(Start, Finish, C, A, B, Operadoras,Visited, [Start | Path]) :-
     arco((C,I,Start,OPF,_,_),_),
     memberchk(OPF, Operadoras), 
	(B>A -> succ(I,T) ; sub(I,T)),
     arco((C,T,X,OP,_,_),_),
     memberchk(OP, Operadoras),   
     \+(memberchk(X, Visited)),
     camQ2(X, Finish, C, A, B, Operadoras, [X | Visited], Path).

comunsLQ2(Ini,Fim,Operadoras,CarrCom):-
     findall(CI,(arco((CI,_,Ini,OPF,_,_),_),(memberchk(OPF, Operadoras))),CarrI),
	sort(CarrI,PI),
	findall(CF,(arco((CF,_,Fim,OP,_,_),_),(memberchk(OP, Operadoras))),CarrF),
	sort(CarrF,PF),
	intersection(PI,PF, CarrCom),
	\+length(CarrCom,0).



%Q3Excluir um ou mais operadores de transporte para o percurso; versão inicial, a da 1ª implementação da base de conhecimento
zeOperadoraExGlobal(Start, Finish, Visited, Operadoras, Path):-
     paragem(_,_,Finish,_,_,_,_,_,OPF,_,_,_),
     not(member(OPF, Operadoras)),
     zeOperadoraEx(Start, Finish, Visited, Operadoras, Path).

zeOperadoraEx(Gid, Gid, _, _,[Gid]).                    
zeOperadoraEx(Start, Finish, Visited, Operadoras, [(C,Start) | Path]) :-   
     paragem(C,I,Start,_,_,_,_,_,OPS,_,_,_),
     not(member(OPS, Operadoras)),   
     succ(I,T),
     paragem(C,T,X,_,_,_,_,_,OPN,_,_,_),
     not(member(OPN, Operadoras)),   
     not(member(X, Visited)),
     zeOperadoraEx(X, Finish, [X | Visited], Operadoras, Path).

%Q3Excluir um ou mais operadores de transporte para o percurso; Versao com comuns.
query3G(Start, Finish, Operadoras, Path,N):-
     arco((_,_,Finish,OPF,_,_),(_,_,_,_,_,_)),
     \+(memberchk(OPF, Operadoras)),   
     (isoladaG(Start,Finish),print("Carreira Isolada");
     query3(Start, Finish, Operadoras,[Start], Path),
     length(Path, N)).   

query3(Gid, Gid,_, _, [Gid]).  
query3(Gid, Gid,_, _, _).                     
query3(Start, Finish, Operadoras, Visited, [Start | Path]) :-
     (comunsQ3(Start,Finish,Operadoras,Path),
     query3(Finish, Finish, Operadoras, Visited, Path));
     (arco((_,_,Start,OPF,_,_),(_,_,X,_,_,_)),
     \+(memberchk(OPF, Operadoras)),   
     \+(memberchk(X, Visited)),
     query3(X, Finish, Operadoras, [X | Visited], Path)).

comunsQ3(Ini,Fim,Operadoras,Cam):-    
     comunsLQ3(Ini,Fim,Operadoras,[C|_]),
     arco((C,A,Ini,OPF,_,_),_),
     \+(memberchk(OPF, Operadoras)),   
     arco((C,B,Fim,OP,_,_),_),
     \+(memberchk(OP, Operadoras)),   
     camQ3(Ini,Fim,C,A,B,Operadoras,[Ini],[_|Cam]).

camQ3(Gid, Gid, _, _, _, _, _, [Gid]).                     
camQ3(Start, Finish, C, A, B, Operadoras,Visited, [Start | Path]) :-
     arco((C,I,Start,OPF,_,_),_),
     \+(memberchk(OPF, Operadoras)), 
	(B>A -> succ(I,T) ; sub(I,T)),
     arco((C,T,X,OP,_,_),_),
     \+(memberchk(OP, Operadoras)),
     \+(memberchk(X, Visited)),
     camQ3(X, Finish, C, A, B, Operadoras, [X | Visited], Path).

comunsLQ3(Ini,Fim,Operadoras,CarrCom):-
     findall(CI,(arco((CI,_,Ini,OPF,_,_),_),(\+(memberchk(OPF, Operadoras)))),CarrI),
	sort(CarrI,PI),
	findall(CF,(arco((CF,_,Fim,OP,_,_),_),(\+(memberchk(OP, Operadoras)))),CarrF),
	sort(CarrF,PF),
	intersection(PI,PF, CarrCom),
	\+length(CarrCom,0).

%Q4Identificar quais as paragens com o maior número de carreiras num determinado percurso.

query4G(Path,C):-
     query4(Path,N),
     keysort(N,S),
     reverse(S, C).
     
query4([],[]).
query4([H|T], [P-H|F]):-
     auxQ4(H,P),
     query4(T,F).
     
maxi(H,P,A,T,X,F):-
     (P>=T,
     X is H,F is P);
     X is A,F is T.

auxQ4(H, N):-
     findall(CI,arco((CI,_,H,_,_,_),_),L),
     sort(L,G),
     length(G,N).
     

%Q7Escolher o percurso que passe apenas por abrigos com publicidade; Versao com comuns
query7G(Start, Finish, Publ, Path,N):-
	arco((_,_,Finish,_,_,Publ),(_,_,_,_,_,_)),
     (isoladaG(Start,Finish),print("Carreira Isolada");
	query7(Start, Finish, Publ, [Start], Path),
	length(Path, N)).

query7(Gid, Gid,_, _, [Gid]).  
query7(Gid, Gid,_, _, _).                     
query7(Start, Finish, Publ, Visited, [Start | Path]) :-
	(comunsQ7(Start,Finish,Publ,Path),
	query7(Finish, Finish,Publ, Visited, Path));
	(arco((_,_,Start,_,_,Publ),(_,_,X,_,_,_)),
	\+(memberchk(X, Visited)),
	query7(X, Finish, Publ,[X | Visited], Path)).

comunsQ7(Ini,Fim,Publ,Cam):-    
	comunsLQ7(Ini,Fim,Publ,[C|_]),
	arco((C,A,Ini,_,_,Publ),_),
	arco((C,B,Fim,_,_,Publ),_),
	camQ7(Ini,Fim,C,A,B,Publ,[Ini],[_|Cam]).

camQ7(Gid, Gid, _, _, _, _, _,[Gid]).                     
camQ7(Start, Finish, C, A, B, Publ, Visited, [Start | Path]) :-
	arco((C,I,Start,_,_,Publ),_),
	(B>A -> succ(I,T) ; sub(I,T)),
     arco((C,T,X,_,_,Publ),_),
	\+(memberchk(X, Visited)),
	camQ7(X, Finish, C, A, B, Publ, [X | Visited], Path).

comunsLQ7(Ini,Fim,Publ,CarrCom):-
	findall(CI,arco((CI,_,Ini,_,_,Publ),_),CarrI),
	sort(CarrI,PI),
	findall(CF,arco((CF,_,Fim,_,_,Publ),_),CarrF),
	sort(CarrF,PF),
	intersection(PI,PF, CarrCom),
	\+length(CarrCom,0).

%Q8Escolher o percurso que passe apenas por paragens abrigadas; Versao comuns
query8G(Start, Finish, Path,N):-
     arco((_,_,Finish,_,AB,_),(_,_,_,_,_,_)),
     \+(memberchk(AB, ['Sem Abrigo'])),   
     (isoladaG(Start,Finish),print("Carreira Isolada");
     query8(Start, Finish, ['Sem Abrigo'],[Start], Path),
     length(Path, N)).   

query8(Gid, Gid,_, _, [Gid]).  
query8(Gid, Gid,_, _, _).                     
query8(Start, Finish, Abri, Visited, [Start | Path]) :-
     (comunsQ8(Start,Finish,Abri,Path),
     query8(Finish, Finish, Abri, Visited, Path));
     (arco((_,_,Start,_,AB,_),(_,_,X,_,_,_)),
     \+(memberchk(AB, Abri)),   
     \+(memberchk(X, Visited)),
     query8(X, Finish, Abri, [X | Visited], Path)).

comunsQ8(Ini,Fim,Abri,Cam):-    
     comunsLQ8(Ini,Fim,Abri,[C|_]),
     arco((C,A,Ini,_,AB,_),_),
     \+(memberchk(AB, Abri)),   
     arco((C,B,Fim,OP,_,_),_),
     \+(memberchk(OP, Abri)),   
     camQ8(Ini,Fim,C,A,B,Abri,[Ini],[_|Cam]).

camQ8(Gid, Gid, _, _, _, _, _, [Gid]).                     
camQ8(Start, Finish, C, A, B, Abri,Visited, [Start | Path]) :-
     arco((C,I,Start,_,AB,_),_),
     \+(memberchk(AB, Abri)), 
	(B>A -> succ(I,T) ; sub(I,T)),
     arco((C,T,X,OP,_,_),_),
     \+(memberchk(OP, Abri)),
     \+(memberchk(X, Visited)),
     camQ8(X, Finish, C, A, B, Abri, [X | Visited], Path).

comunsLQ8(Ini,Fim,Abri,CarrCom):-
     findall(CI,(arco((CI,_,Ini,_,AB,_),_),(\+(memberchk(AB, Abri)))),CarrI),
	sort(CarrI,PI),
	findall(CF,(arco((CF,_,Fim,OP,_,_),_),(\+(memberchk(OP, Abri)))),CarrF),
	sort(CarrF,PF),
	intersection(PI,PF, CarrCom),
	\+length(CarrCom,0).

%Q9Escolher um ou mais pontos intermédios por onde o percurso deverá passar
query9G(Start,Finish,Inter,Path,N):-
     query9(Start,Finish,Inter,Path),
     length(Path,N).

query9(X,Finish,[],Path):-
     zefAdjQ9(X,Finish,Path).
query9(Start, Finish, [H|T], F):-
     zefAdjQ9(Start,H,P),
     query9(H,Finish,T,[_|Tail]),
     append(P, Tail, F).
     
zefAdjQ9(Start, Finish, Path):-
	arco((_,_,Finish,_,_,_),(_,_,_,_,_,_)),
     (isoladaG(Start,Finish),print("Carreira Isolada");
	zefa(Start, Finish, [Start], Path)).


