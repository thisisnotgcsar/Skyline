
<h1 style="text-align: center;">Elaborato High Performance Computing</h1>
<p style="text-align: right; font-style: italic; font-size:150%; margin: auto">
<i>Giulio Golinelli</i>
<br>
<i>0000883007</i>
<br>
<i>23/02/2021</i>
</p>

# Tabella dei contenuti <!-- omit in toc -->

- [Introduzione](#introduzione)
- [versione Open-MP](#versione-open-mp)
  - [Parallelizzazione](#parallelizzazione)
  - [Analisi](#analisi)
- [Versione MPI](#versione-mpi)
- [Conclusione](#conclusione)
- [Riferimenti bibliografici](#riferimenti-bibliografici)

# Introduzione  
Il lavoro svolto consiste nella parallelizazione dell'algoritmo *"Skyline"* sfruttando due tecnlogie: Open-MP e MPI.  
La versione seriale del programma era fornita ed è stata fortemente utilizzata come base su cui sviluppare le altre due versioni.  
È stato inoltre sviluppato uno script bash chiamato *"script.sh"* per automatizzare la compilazione, esecuzione e verifica dei vari sorgenti.  
Si sono eseguiti diversi test sul server *isi-raptor03.csr.unibo.it*, raccolti i rispettivi tempi di esecuzione e elaborato dei risultati su diverse caratteristiche, di seguito presentati.

**N.B.**: Si assume che il lettore abbia una piena conoscenza di:
 - Obbiettivo e struttura dell'algoritmo skyline
 - Architettura e funzionamento delle macchine multiprocessore, sia a memoria condivisa che a memoria distribuita
 - Linguaggio C e fondamenti di programmazione
 - Pattern di programmazione parallela 
 - Analisi delle prestazioni dei programmi paralleli
 - Tecnologie Open-MP e MPI

**N.B.**: Le versioni parallelizzate degli algoritmi sono state lasciate quanto più simili alla versione seriale fornita in modo da facilitarne la comprensione e utilizzare quest'ultima come punto di riferimento nelle loro spiegazioni.

# versione Open-MP
## Parallelizzazione
Il for interno modifica elementi del vettore che saranno poi i soggetti delle iterazione successive del for più esterno.  
Il for più esterno segue un percorso critico in quanto diventa obbligatorio che le iterazioni del for interno avvengano prima di una sua successiva.  
Diventa quindi possibile parallelizzare solamente il for più interno che comuqnue costituisce la maggior parte del costo computazionale dell'intero algoritmo.  
Nasce tuttavia non poco onore computazionale aggiuntivo in quanto ogni volta che il ciclo esterno trova un possible candidato allo skyline, è necessario avviare la computazione parallela e sincronizzare i risultati una volta finita.  
Non sono state modificate le politiche di scheduling di default.  
È stata inserita una operazione di riduzione per sincronizzare ogni volta il numero di punti rimanenti nello skyline.
## Analisi
test4
s 25.72
o 3.31
m 7.26

# Versione MPI

# Conclusione

# Riferimenti bibliografici
