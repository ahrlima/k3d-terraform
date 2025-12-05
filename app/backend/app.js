const express = require('express');
const app = express();
const port = 3000;

app.get('/api/dados', (req, res) => {
  res.json({
    message: 'Estes são dados dummy do backend!',
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Backend dummy rodando em http://localhost:${port}`);
});
