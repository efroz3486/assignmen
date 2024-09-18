const express = require('express');
const axios = require('axios');
const app = express();
const port = 3001;

app.get('/api/weather', async (req, res) => {
  const city = req.query.city;
  const apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  const url = `http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`;

  try {
    const response = await axios.get(url);
    res.json(response.data);
  } catch (error) {
    res.status(500).send('Error fetching weather data');
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

