import React, { useState } from 'react';

function App() {
  const [city, setCity] = useState('');
  const [weather, setWeather] = useState(null);

  const getWeather = async () => {
    const response = await fetch(`/api/weather?city=${city}`);
    const data = await response.json();
    setWeather(data);
  };

  return (
    <div>
      <h1>Weather App</h1>
      <input value={city} onChange={(e) => setCity(e.target.value)} placeholder="Enter city" />
      <button onClick={getWeather}>Get Weather</button>
      {weather && (
        <div>
          <h2>{weather.name}: {weather.weather[0].description}</h2>
        </div>
      )}
    </div>
  );
}

export default App;

