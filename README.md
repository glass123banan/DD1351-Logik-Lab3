# DD1351 Logik för dataloger  
## Laboration 3: Modellprovning för CTL  
**D. Gurov, A. Lundblad, K. Palmskog**  
*1 december 2022*

---

## 1. Introduktion

En modellprovare (*model checker*) är ett programverktyg som kontrollerar om en temporallogisk formel φ gäller i ett visst tillstånd \( s \) i en given modell \( M \), dvs kontrollerar om \( M, s \models \phi \) gäller. I denna laboration utvecklas och testas en modellprovare för en delmängd av reglerna i temporallogiken CTL.

Modellprovning handlar om att avgöra validiteten. Genom bevisökning kan detta göras då bevissystemet är både **sunt** och **fullständigt**. Det tillåter användning av flera bevisträd för en given formel och modell med ett ändligt antal tillstånd.

### Syftet med laborationen är att lära sig:  
- bygga enkla men nyttiga programverktyg,  
- modellera systembeteende med övergångssystem,  
- specificera systembeteendeegenskaper med CTL,  
- verifiera egenskaperna med verktyget man har byggt.

### CTL-formler
Vi behandlar följande delmängd av den temporala logiken CTL:  
\[
\phi ::= p \mid \neg p \mid \phi \land \phi \mid \phi \lor \phi \mid AX\phi \mid AG\phi \mid AF\phi \mid EX\phi \mid EG\phi \mid EF\phi
\]

Semantiken för CTL-formler är definierad i kursbokens **Definition 3.15** (sid. 211). Modeller (även kallade transitionssystem) är definierade i **Definition 3.4** (sid. 178). Viktiga specifikationsmönster finns i **avsnitt 3.4.3** (sid. 215).

---

## 2. Ett bevissystem för CTL

### Grundprinciper:
Bevissystemet (se figur 1) bygger på idén att G- och F-formler kan “vecklas ut” och evalueras rekursivt. För att garantera att bevisökningen terminerar används en lista \( U \) för att spåra tillstånd där en formel redan har evaluerats.  
- **G-formler**: Slingor i modellen innebär "success".  
- **F-formler**: Slingor innebär "failure".

### Syntaktiska sekventer
Sekventen \( M, s \vdash_U \phi \) används, vilket motsvarar den semantiska sekventen \( M, s \models \phi \), men med tillägg av listan \( U \).

#### Regler:
- För \( AX \)-regler betecknar \( s_1, \dots, s_n \) alla efterföljare till \( s \).  
- För \( EX \)-regler betecknar \( s' \) någon efterföljare till \( s \).

---

## 3. Modeller i Prolog

### Representation av modeller
I modellen \( M = (S, \rightarrow, L) \):  
- **Tillståndsmängden \( S \)** representeras som en lista av möjliga tillstånd (men används ej direkt).  
- **Transitionsrelationen \( \rightarrow \)** representeras av grannlistor: varje tillstånd \( s \) har en lista av efterföljare \( s_1, \dots, s_n \).  
- **Sanningstilldelningen \( L \)** anges genom en lista av variabler som gäller för varje tillstånd.

**Exempelmodell** (motsvarar bokens sid. 179, figur 3.3): 
![image info](./img/figur1)

![image info](./img/figur2)


Formler representeras på samma sätt som i labb 1: små bokstäver är variabler, och således även formler. Om F och G är formler så är `and(F,G)`, `or(F,G)`, `ax(F)`, `ag(F)`, `af(F)`, `ex(F)`, `eg(F)` och `ef(F)` också giltiga formler.

## 4 Uppgifter

Labbuppgiften består av följande deluppgifter:

### 1. Verktygsutveckling
Skriv en modellprovare för CTL i Prolog som gör bevisökning i bevissystemet från figur 1. Observera att om ni avviker från reglerna i bevissystemet så måste ni argumentera för att det nya systemet är sunt. Ett programskelett hittar ni sist i detta labbpek.

### 2. Modellering
Tänk på något system med datalogisk relevans som har ett icke-trivialt beteende. Konstruera en modell \( M \) till beteendet, och rita dess tillståndsgraf. Helt abstrakta modeller som bara har tillståndsnamn som \( s_0 \) och \( s_1 \) är inte att betrakta som meningsfulla, och icke-triviala modeller har rimligen fem eller fler tillstånd. Ge en intuitiv förklaring till beteendet som modelleras och ditt val av atomer. Skapa en Prolog-kompatibel representation (som beskrivet ovan) av modellen.

\[
M = (S, \to, L) \quad \text{där} \quad S = \{s_0, s_1, s_2\}, \to = \{(s_0, s_1), (s_0, s_2), (s_1, s_0), (s_1, s_2), (s_2, s_2)\}, L = \{s_0 : \{p,q\}, s_1 : \{q,r\}, s_2 : \{r\}\}
\]

### 3. Specifiering
Konstruera minst två icke-triviala och meningsfulla systemegenskaper uttryckta som CTL-formler relaterade till er modell, en som håller och en som inte håller. Förklara vilka beteendeegenskaper de formaliserar. Tänk på att man ska utgå bara från atommängden när man formaliserar egenskaper, och inte från något konkret modell.

### 4. Verifiering
Kontrollera med er modellprovare att systemegenskaperna håller eller inte håller som förväntat. Kör dessutom alla fördefinierade testfall (se tips nedan).

### 5. Rapport
Sammanställ alla resultat i en rapport. Rapporten lämnas in och fungerar som underlag vid redovisningen. Rapporten ska vara strukturerad, välskriven, och heltäckande. Inkludera även en tabell i rapporten som listar namnen på era predikat och när vardera predikat är sant respektive falskt samt ett appendix med programkoden, exempelmodellen, och formlerna som formaliserar beteendeegenskaperna.

### 6. Redovisning
Förutom att diskutera hur ni implementerat bevissystemet ska ni vara redo att svara på följande frågor:
- (a) Vad skiljer labbens version av CTL från bokens version? Hur kan man utöka modellprovaren så att den hanterar bokens CTL?
- (b) Hur hanterade ni variabelt antal premisser (som i AX-regeln)?
- (c) Hur stora modeller och formler går det att verifiera med er modellprovare?

## 5 Tips

- På Canvas finner du en uppsättning testfall. I allmänhet måste er lösning passera alla tester (det kan finnas undantagsfall, t.ex. om ni kan argumentera för att en korrekt lösning inte nödvändigtvis ska godta ett visst testfall). Testsviten är inte heller uttömmande, så en lösning är inte nödvändigtvis korrekt även om alla tester passerar. För att köra alla tester kan ni kopiera hela testkatalogen till er labbkatalog och använda skriptet `run_all_tests` eller Prologprogrammet `run_all_tests.pl`. Så här kan förloppet se ut:

```bash
$ cd tests
$ prolog
GNU Prolog 1.3.0
By Daniel Diaz
Copyright (C) 1999-2007 Daniel Diaz
| ?- ['run_all_tests.pl'].
compiling run_all_tests.pl for byte code...
tests/run_all_tests.pl compiled, ...
yes
| ?- run_all_tests('../DIN_PROLOG_FIL.pl').
compiling DIN_PROLOG_FIL.pl for byte code...
valid001.txt passed
valid003.txt passed
valid007.txt passed
valid013.txt passed
...
```

- Genom att ge kommandot `trace.` innan ni kör ert program instruerar ni Prolog att skriva ut vad den gör, vad det lyckas bevisa och vad den misslyckas med att bevisa. Använd kommandot `notrace.` för att stänga av utskrifterna.
- Tänk på att i vissa Prolog-tolkar som gprolog så måste definitionen av ett predikat vara “sammanhängande” i filen. Om ni “delar upp” predikat på följande sätt:

```prolog
predA(...) :- ... % Börja definera predA
predB(...) :- ... % Definera predB
predA(...) :- ... % Fortsätt definera predA (FUNGERAR EJ)
```

kommer ni få ett felmeddelande i stil med:

```
warning: discontiguous predicate pred/1 - clause ignored
```

- Om något test inte ger det förväntade resultatet, försök ta bort irrelevanta delar av indata (dvs. konstruera ett minimalt motexempel) innan ni debuggar med trace. Att stega igenom en stor Prolog-körning leder sällan någon vart.

- Ett sätt att avlusa ert program är att lägga till utskrifter. För att till exempel se att en regel EF1 har applicerats kan ni lägga till write('used EF1\n') sist i implementationen av EF1.

- Om ert program verkar hamna i en oändlig slinga, säkerställ att ni lagt in kod för att kontrollera regelvillkoren s ∈ U och s ∈/ U överallt där det behövs.

## Programskelett
```
% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).

% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(T), read(L), read(S), read(F), seen,
    check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid. %
% (T,L), S |- F %U

% To execute: consult('your_file.pl'). verify('input.txt').

% Literals
%check(_, L, S, [], X) :- ... 
%check(_, L, S, [], neg(X)) :- ...

% And
%check(T, L, S, [], and(F,G)) :- ...

% Or
% AX
% EX
% AG
% EG
% EF
% AF
```
