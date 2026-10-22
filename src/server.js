const express = require('express');

const app = express();
const PORT = process.env.PORT || 80;

app.use(express.json());

// Requisito del proyecto: una ruta / que devuelva "Hello, world!"
app.get('/', (req, res) => {
  res.send('Hello, world!');
});

// Endpoint de health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', uptime: process.uptime() });
});

// Si se ejecuta directamente (node src/server.js), inicia el listener
if (require.main === module) {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Servidor Node.js escuchando en el puerto ${PORT}`);
  });
}

module.exports = app;
