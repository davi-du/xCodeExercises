// server.js
// API con due GET (customer, transactions) e una POST (aggiunge una transazione)

const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = 3000;
const DATA_FILE = path.join(__dirname, 'data.json');

app.use(express.json());

function fetchData() {
  const contenuto = fs.readFileSync(DATA_FILE, 'utf-8');
  return JSON.parse(contenuto);
}

function addTransaction(dati) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(dati, null, 2), 'utf-8');
}

app.get('/data', (req, res) => {
  const data = fetchData();
  res.json(data);
});

app.post('/transactions', (req, res) => {
  const { title, date, amount, category } = req.body;

  if (!title || !date || amount === undefined || !category) {
    return res.status(400).json({
      errore: 'Campi mancanti.'
    });
  }

  const data = fetchData();

  const nuovaTransazione = {
    id: crypto.randomUUID(),
    title,
    date,
    amount,
    category
  };

  data.transactions.push(nuovaTransazione);
  addTransaction(data);

  res.status(201).json(nuovaTransazione);
});

app.listen(PORT, () => {
  console.log(`Server avviato su http://localhost:${PORT}`);
});