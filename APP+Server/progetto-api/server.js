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

function saveData(dati) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(dati, null, 2), 'utf-8');
}

function round2(valore) {
  return Math.round(valore * 100) / 100;
}

function trovaUtente(data, username) {
  return data.users.find(u => u.credentials.username === username);
}

// ---- Password: hashing con scrypt (built-in in Node, nessuna dipendenza esterna) ----

function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.scryptSync(password, salt, 64).toString('hex');
  return `${salt}:${hash}`;
}

function verifyPassword(password, stored) {
  const [salt, hash] = stored.split(':');
  const hashDaVerificare = crypto.scryptSync(password, salt, 64).toString('hex');
  const a = Buffer.from(hash, 'hex');
  const b = Buffer.from(hashDaVerificare, 'hex');
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

// ---- Token: stesso principio di un JWT (header.payload.firma, firmato con HMAC-SHA256), ----
// ---- implementato con crypto nativo cosi non serve installare la libreria jsonwebtoken. ----

// In produzione questo va in una variabile d'ambiente, non hardcoded nel codice.
const TOKEN_SECRET = process.env.TOKEN_SECRET || 'demo-secret-da-cambiare-in-produzione';
const TOKEN_TTL_MS = 2 * 60 * 60 * 1000; // 2 ore

function base64url(input) {
  return Buffer.from(input).toString('base64')
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function base64urlDecode(input) {
  input = input.replace(/-/g, '+').replace(/_/g, '/');
  while (input.length % 4) input += '=';
  return Buffer.from(input, 'base64').toString('utf-8');
}

function createToken(payload) {
  const header = { alg: 'HS256', typ: 'JWT' };
  const body = { ...payload, exp: Date.now() + TOKEN_TTL_MS };
  const headerPart = base64url(JSON.stringify(header));
  const bodyPart = base64url(JSON.stringify(body));
  const signature = crypto.createHmac('sha256', TOKEN_SECRET)
    .update(`${headerPart}.${bodyPart}`)
    .digest('base64')
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  return `${headerPart}.${bodyPart}.${signature}`;
}

function verifyToken(token) {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [headerPart, bodyPart, signature] = parts;

  const expectedSignature = crypto.createHmac('sha256', TOKEN_SECRET)
    .update(`${headerPart}.${bodyPart}`)
    .digest('base64')
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');

  const a = Buffer.from(signature);
  const b = Buffer.from(expectedSignature);
  if (a.length !== b.length) return null;
  if (!crypto.timingSafeEqual(a, b)) return null;

  const body = JSON.parse(base64urlDecode(bodyPart));
  if (body.exp && Date.now() > body.exp) return null; // scaduto

  return body;
}

// ---- Middleware: protegge le rotte che richiedono autenticazione ----

function authenticateToken(req, res, next) {
  const header = req.headers['authorization'];

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ errore: 'Token mancante.' });
  }

  const token = header.slice('Bearer '.length);
  const payload = verifyToken(token);

  if (!payload) {
    return res.status(401).json({ errore: 'Token non valido o scaduto.' });
  }

  req.user = payload;
  next();
}

app.post('/login', (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ errore: 'Nome utente e password sono obbligatori.' });
  }

  const data = fetchData();
  const utente = trovaUtente(data, username);

  if (!utente || !verifyPassword(password, utente.credentials.password)) {
    return res.status(401).json({ errore: 'Credenziali non valide.' });
  }

  const token = createToken({ username });
  res.json({ token });
});

app.get('/data', authenticateToken, (req, res) => {
  const data = fetchData();
  const utente = trovaUtente(data, req.user.username);

  if (!utente) {
    return res.status(404).json({ errore: 'Utente non trovato.' });
  }

  // Restituisco solo i dati di QUESTO utente: mai credentials, mai i dati di altri utenti.
  res.json({
    customer: utente.customer,
    transactions: utente.transactions
  });
});

app.post('/transactions', authenticateToken, (req, res) => {
  const { title, date, amount, category, beneficiary, beneficiaryIban } = req.body;

  if (!title || !date || amount === undefined || !category) {
    return res.status(400).json({
      errore: 'Campi mancanti.'
    });
  }

  const data = fetchData();
  const utente = trovaUtente(data, req.user.username);

  if (!utente) {
    return res.status(404).json({ errore: 'Utente non trovato.' });
  }

  const nuovaTransazione = {
    id: crypto.randomUUID(),
    title,
    date,
    amount,
    category,
    ...(beneficiary ? { beneficiary } : {}),
    ...(beneficiaryIban ? { beneficiaryIban } : {})
  };

  utente.transactions.push(nuovaTransazione);

  // Aggiorna il saldo SOLO dell'utente autenticato (positivo = entrata, negativo = uscita).
  utente.customer.accountBalance = round2(utente.customer.accountBalance + amount);

  saveData(data);

  res.status(201).json(nuovaTransazione);
});

app.listen(PORT, () => {
  console.log(`Server avviato su http://localhost:${PORT}`);
});