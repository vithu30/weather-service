# Mock Weather Service

This is a mock SOAP weather service (SOAP12 version) which has two resources. 
1. GET resource

### Sample request 
```
curl -X GET http://localhost:9090/weather/
```

### Sample response
```
Successful Invocation!
```

2. POST resource

### Sample SOAP request
```
<soap12:Envelope xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <soap12:Body>
      <GetWeather xmlns="http://www.webserviceX.NET">
        <CityName>Colombo</CityName>
      </GetWeather>
    </soap12:Body>
  </soap12:Envelope>
```

### Sample response
```
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
    <soap:Body>
        <m0:getWeatherResponse xmlns:m0="http://services.samples">
            <m0:WeatherResult>
                <m0:Location>Colombo</m0:Location>
                <m0:Temperature>37</m0:Temperature>
                <m0:RelativeHumidity>73</m0:RelativeHumidity>
            </m0:WeatherResult>
        </m0:getWeatherResponse>
    </soap:Body>
</soap:Envelope>
```