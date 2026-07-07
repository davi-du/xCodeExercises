# Progetto API - DemoApp

API Node.js con Express che espone i dati del cliente e le transazioni, usate dall'app iOS DemoApp.

## Requisiti

- [Node.js](https://nodejs.org) (versione LTS consigliata)
- VS Code (o un altro editor a scelta)

Per verificare se Node è già installato, apri un terminale e digita:

node -v
npm -v


Se vedi due numeri di versione, Node è già pronto e puoi saltare all'installazione delle dipendenze.

## Struttura del progetto

progetto-api/
├── server.js       # il server Express con le route
├── data.json       # i dati (cliente + transazioni), modificati anche a runtime
├── package.json    # dipendenze del progetto
└── README.md


## Avvio (prima volta)

1. Apri la cartella `progetto-api` in VS Code (**File → Open Folder...**)
2. Apri il terminale integrato (**Terminal → New Terminal**)
3. Installa le dipendenze:

   npm install


4. Avvia il server:

   node server.js


5. Se tutto è andato bene, nel terminale vedrai:

   Server avviato su http://localhost:3000


Lascia questo terminale aperto: il server resta in ascolto finché non lo fermi (ctrl + C).


## Endpoint disponibili

| Metodo | Endpoint         | Descrizione                                       |
|--------|------------------|----------------------------------------------------|
| GET    | `/data`          | Restituisce cliente + transazioni in un unico JSON |
| POST   | `/transactions`  | Aggiunge una nuova transazione                     |

### Esempio body per la POST

```json
{
  "title": "Cena",
  "date": "2026-07-06T20:00:00+0000",
  "amount": -25.50,
  "category": "Ristorante"
}
```

## Test rapido dal browser

Con il server avviato, apri:

http://localhost:3000/data

Se vedi il JSON con `customer` e `transactions`, il server funziona correttamente.


## Note per l'app iOS

- Se testi su **Simulatore iOS**: `http://localhost:3000` funziona così com'è.
- Se testi su **iPhone fisico**: sostituisci `localhost` con l'IP locale del tuo computer (es. `http://192.168.1.23:3000`), trovabile con:

  ipconfig getifaddr en0   

- Ricorda di aggiungere l'eccezione ATS (`NSAllowsLocalNetworking`) nelle impostazioni Info del target Xcode, altrimenti iOS blocca le richieste `http://` non cifrate.