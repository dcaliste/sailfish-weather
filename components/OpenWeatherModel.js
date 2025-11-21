// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause
//
// @author Anton Turko <turok@duck.com>


function handleCurrentWeatherResult(result) {
    if (result === undefined || result.main.temp === "") {
        return undefined;
    }

    var weather = getWeatherData(result);
    weather.lat = result.lat;
    weather.lon = result.lon;
    weather.timestamp = new Date(result.dt * 1000);
    weather.temperature = result.main.temp;
    weather.feelsLikeTemperature = result.main.feels_like;
    return weather;
}

function handleForecastResult(result, hourly, visibleCount, minimumHourlyRange) {
    var forecast = result.list;
    if (result.length === 0 || forecast.length === 0) {
        return undefined;
    }

    var weatherData = []
    for (var i = 0; i < forecast.length; i++) {
        var data = forecast[i]
        var weather = getWeatherData(data)
        weather.timestamp = new Date(data.dt * 1000)
        weather.temperature = data.main.temp
        if (!hourly) {
            weather.accumulatedPrecipitation = data.rain === undefined ? data.snow === undefined ? 0 : data.snow["3h"] : data.rain["3h"]
            weather.maximumWindSpeed = data.wind.speed
            weather.windDirection = data.wind.deg
            weather.high = data.main.temp_max
            weather.low = data.main.temp_min
        }
        weatherData[weatherData.length] = weather
    }

    if (hourly) {
        var minimumTemperature = weatherData[0].temperature
        var maximumTemperature = weatherData[0].temperature
        for (i = 1; i < visibleCount + 1; i++) {
            var temperature = weatherData[i].temperature
            minimumTemperature = Math.min(minimumTemperature, temperature)
            maximumTemperature = Math.max(maximumTemperature, temperature)
        }
        var range = maximumTemperature - minimumTemperature
        if (range < minimumHourlyRange) {
            minimumTemperature -= Math.floor((minimumHourlyRange - range ) / 2)
            range = minimumHourlyRange
        }

        for (i = 0; i < visibleCount + 1; i++) {
            weatherData[i].relativeTemperature = (weatherData[i].temperature - minimumTemperature) / range;
            weatherData[i].temperature = Math.floor(weatherData[i].temperature);
        }
    } else {
        var groupedByDay = weatherData.reduce(function(container, weather) {
            var timestamp = weather.timestamp
            var year = timestamp.getFullYear()
            var month = timestamp.getMonth()
            var day = timestamp.getDate()
            var key = [year, month, day].join("-")
            if (!container[key]) {
                container[key] = []
            }
            container[key].push(weather)
            return container
        }, {})

        var weatherDayByDay = []
        for(var date in groupedByDay) {
            var weathers = groupedByDay[date];
            weather = weathers[0];
            var precipitation = 0
            minimumTemperature = weather.temperature;
            maximumTemperature = weather.temperature;
            var middayDate = new Date(weather.timestamp);
            middayDate.setHours(12);
            middayDate.setMinutes(0);
            var dateDiff = Math.abs(weather.timestamp - middayDate);
            for (i = 1; i < weathers.length; i++) {
                precipitation += weather.accumulatedPrecipitation
                temperature = weathers[i].temperature;
                minimumTemperature = Math.min(minimumTemperature, temperature);
                maximumTemperature = Math.max(maximumTemperature, temperature);
                var diff = Math.abs(weathers[i].timestamp - middayDate);
                if (diff < dateDiff) {
                    weather = weathers[i];
                    dateDiff = diff;
                }
            }
            weather.accumulatedPrecipitation = precipitation
            weather.high = Math.floor(maximumTemperature);
            weather.low = Math.round(minimumTemperature);
            weatherDayByDay[weatherDayByDay.length] = weather;
        }

        weatherData = weatherDayByDay
    }

    return weatherData;
}

function handleSearchLocationResult(result) {
    var locations = result
    if (result === undefined || result.length === 0) {
        return undefined
    }

    for (var i = 0; i < locations.length; i++) {
        var location = locations[i]
        location.id = location.place_id
        location.country = location.display_name
    }
    return locations
}

function handleObservationResult(result) {
    if (result === undefined) {
        return "";
    }

    return result.name;
}

function mapOpenWeatherToForeca(openWeatherId) {
    switch(openWeatherId) {
        case 800: return "000" // Clear
        case 801: return "100" // Mostly clear
        case 802: return "200" // Partly cloudy
        case 803: return "300" // Cloudy
        case 804: return "400" // Overcast
        case 701: return "600" // Fog
        case 711: return "600" // Fog
        case 721: return "600" // Fog
        case 731: return "600" // Fog
        case 741: return "600" // Fog
        case 751: return "600" // Fog
        case 761: return "600" // Fog
        case 762: return "600" // Fog
        case 771: return "600" // Fog
        case 781: return "600" // Fog
        case 600: return "212" // Partly cloudy and light snow
        case 601: return "312" // Cloudy and light snow
        case 602: return "412" // Overcast and light snow
        case 611: return "211" // sleet
        case 612: return "311" // light shower sleet
        case 613: return "411" // shower sleet
        case 615: return "221" // light rain and snow
        case 616: return "421" // rain and snow
        case 620: return "222" // Partly cloudy and snow showers
        case 621: return "322" // Cloudy and snow showers
        case 622: return "422" // Overcast and snow showers
        case 500: return "210" // Partly cloudy and light rain
        case 501: return "310" // Cloudy and light rain
        case 502: return "410" // Overcast and light rain
        case 503: return "410" // Overcast and rain
        case 504: return "420" // Overcast and light rain
        case 511: return "410" // Overcast and light rain
        case 520: return "220" // Partly cloudy and showers
        case 521: return "320" // Cloudy and showers
        case 522: return "420" // Overcast and showers
        case 531: return "430" // Cloudy and showers
        case 300: return "210"
        case 301: return "310"
        case 302: return "410"
        case 310: return "210"
        case 311: return "310"
        case 312: return "220"
        case 313: return "320"
        case 314: return "420"
        case 314: return "430"
        case 200: return "240" // Partly cloudy, possible thunderstorms with rain
        case 201: return "340" // Cloudy, thunderstorms with rain
        case 202: return "440" // Overcast, thunderstorms with rain
        case 210: return "240"
        case 211: return "340"
        case 212: return "440"
        case 221: return "440"
        case 230: return "240"
        case 231: return "340"
        case 232: return "440"
        default: {
            console.log("Mapping not found for openWeatherId: ", openWeatherId)
            return null // No mapping found
        }
    }
}

function updateAllowed(interval) {
    // only update automatically if more than <interval> minutes has
    // passed since the last update (default 30mins: 30*60*1000)
    // or the date has changed
    interval = interval === undefined ? 30*60*1000 : interval
    var now = new Date()
    var updateAllowed = now.getDate() != lastUpdate.getDate() || (now - interval > lastUpdate)
    if (updateAllowed) {
        lastUpdate = now
    }
    return updateAllowed
}

function getWeatherData(weather) {
    var id = weather.weather[0].id
    var timeSymbol = weather.weather[0].icon.charAt(2)
    var symbol = timeSymbol + mapOpenWeatherToForeca(id)
    var precipitationRateCode = symbol.charAt(2)
    var precipitationRate = ""
    switch (precipitationRateCode) {
    case '0':
        //% "No precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_none")
        break
    case '1':
        //% "Slight precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_slight")
        break
    case '2':
        //% "Showers"
        precipitationRate = qsTrId("weather-la-precipitation_showers")
        break
    case '3':
        //% "Precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_normal")
        break
    case '4':
        //% "Thunder"
        precipitationRate = qsTrId("weather-la-precipitation_thunder")
        break
    default:
        console.log("WeatherModel warning: invalid precipitation rate code", precipitationRateCode)
        break
    }

    var precipitationType = ""
    if (precipitationRateCode === '0') { // no rain
        //% "None"
        precipitationType = qsTrId("weather-la-precipitationtype_none")
    } else {
        var precipitationTypeCode = symbol.charAt(3)
        switch (precipitationTypeCode) {
        case '0':
            //% "Rain"
            precipitationType = qsTrId("weather-la-precipitationtype_rain")
            break
        case '1':
            //% "Sleet"
            precipitationType = qsTrId("weather-la-precipitationtype_sleet")
            break
        case '2':
            //% "Snow"
            precipitationType = qsTrId("weather-la-precipitationtype_snow")
            break
        default:
            console.log("WeatherModel warning: invalid precipitation type code", precipitationTypeCode)
            break
        }
    }

    var data = {
        "description": description(symbol),
        "weatherType": weatherType(symbol),
        "cloudiness": weather.clouds.all,
        "precipitationRate": precipitationRate,
        "precipitationType": precipitationType
    }
    return data
}

function weatherType(code) {
    // just direct mapping, but ensure we receive valid data
    if (code.length === 4) {
        return code
    } else {
        console.warn("Invalid weather code")
        return ""
    }
}

function description(code) {
    var localizations = {
        //% "Clear"
        "000": qsTrId("weather-la-description_clear"),
        //% "Mostly clear"
        "100": qsTrId("weather-la-description_mostly_clear"),
        //% "Partly cloudy"
        "200": qsTrId("weather-la-description_partly_cloudy"),
        //% "Cloudy"
        "300": qsTrId("weather-la-description_cloudy"),
        //% "Overcast"
        "400": qsTrId("weather-la-description_overcast"),
        //% "Thin high clouds"
        "500": qsTrId("weather-la-description-thin_high_clouds"),
        //% "Fog"
        "600": qsTrId("weather-la-description-fog"),
        //% "Partly cloudy and light rain"
        "210": qsTrId("weather-la-description_partly_cloudy_and_light_rain"),
        //% "Cloudy and light rain"
        "310": qsTrId("weather-la-description_cloudy_and_light_rain"),
        //% "Overcast and light rain"
        "410": qsTrId("weather-la-description_overcast_and_light_rain"),
        //% "Partly cloudy and showers"
        "220": qsTrId("weather-la-description_partly_cloudy_and_showers"),
        //% "Cloudy and showers"
        "320": qsTrId("weather-la-description_cloudy_and_showers"),
        //% "Overcast and showers"
        "420": qsTrId("weather-la-description_overcast_and_showers"),
        //% "Overcast and rain"
        "430": qsTrId("weather-la-description_overcast_and_rain"),
        //% "Partly cloudy, possible thunderstorms with rain"
        "240": qsTrId("weather-la-description_partly_cloudy_possible_thunderstorms_with_rain"),
        //% "Cloudy, thunderstorms with rain"
        "340": qsTrId("weather-la-description_cloudy_thunderstorms_with_rain"),
        //% "Overcast, thunderstorms with rain"
        "440": qsTrId("weather-la-description_overcast_thunderstorms_with_rain"),
        //% "Partly cloudy and light wet snow"
        "211": qsTrId("weather-la-description_partly_cloudy_and_light_wet_snow"),
        //% "Cloudy and light wet snow"
        "311": qsTrId("weather-la-description_cloudy_and_light_wet_snow"),
        //% "Overcast and light wet snow"
        "411": qsTrId("weather-la-description_overcast_and_light_wet_snow"),
        //% "Partly cloudy and wet snow showers"
        "221": qsTrId("weather-la-description_partly_cloudy_and_wet_snow_showers"),
        //% "Cloudy and wet snow showers"
        "321": qsTrId("weather-la-description_cloudy_and_wet_snow_showers"),
        //% "Overcast and wet snow showers"
        "421": qsTrId("weather-la-description_overcast_and_wet_snow_showers"),
        //% "Overcast and wet snow"
        "431": qsTrId("weather-la-description_overcast_and_wet_snow"),
        //% "Partly cloudy and light snow"
        "212": qsTrId("weather-la-description_partly_cloudy_and_light_snow"),
        //% "Cloudy and light snow"
        "312": qsTrId("weather-la-description_cloudy_and_light_snow"),
        //% "Overcast and light snow"
        "412": qsTrId("weather-la-description_overcast_and_light_snow"),
        //% "Partly cloudy and snow showers"
        "222": qsTrId("weather-la-description_partly_cloudy_and_snow_showers"),
        //% "Cloudy and snow showers"
        "322": qsTrId("weather-la-description_cloudy_and_snow_showers"),
        //% "Overcast and snow showers"
        "422": qsTrId("weather-la-description_overcast_and_snow_showers"),
        //% "Overcast and snow"
        "432": qsTrId("weather-la-description_overcast_and_snow")
    }

    return localizations[code.substr(1,3)]
}
