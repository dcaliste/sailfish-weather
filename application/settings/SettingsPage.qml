// SPDX-FileCopyrightText: 2014 - 2023 Jolla Ltd.
// SPDX-FileCopyrightText: 2024 - 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.sailfishos.weather.settings 1.0
import Nemo.Configuration 1.0
import com.jolla.settings 1.0

ApplicationSettings {
    id: root
    ConfigurationValue {
        id: temperatureUnitValue
        key: "/sailfish/weather/temperature_unit"
        defaultValue: "celsius"
    }
    ConfigurationValue {
        id: weatherDataProvider
        key: "/sailfish/weather/data_provider"
        defaultValue: "foreca"
    }

    ComboBox {
        //% "Temperature units"
        label: qsTrId("weather_settings-la-temperature_units")
        Component.onCompleted: {
            switch (temperatureUnitValue.value) {
            case "celsius":
                currentIndex = 0
                break
            case "fahrenheit":
                currentIndex = 1
                break
            default:
                console.log("WeatherSettings: Invalid temperature unit value", temperatureUnitValue.value)
                break
            }
        }

        menu: ContextMenu {
            MenuItem {
                //% "Celsius"
                text: qsTrId("weather_settings-me-celsius")
                onClicked: temperatureUnitValue.value = "celsius"
            }
            MenuItem {
                //% "Fahrenheit"
                text: qsTrId("weather_settings-me-fahrenheit")
                onClicked: temperatureUnitValue.value = "fahrenheit"
            }
        }
    }

    ComboBox {
        //% "Weather Provider"
        label: qsTrId("weather_settings-la-weather-provider")
        Component.onCompleted: {
            var splitValues = weatherDataProvider.value.split(':')
            switch (splitValues[0]) {
            case "foreca":
                currentIndex = 0
                break
            case "open_weather":
                currentIndex = 1
                break
            default:
                console.log("WeatherSettings: Invalid weather provider value", weatherDataProvider.value)
                break
            }
        }

        menu: ContextMenu {
            MenuItem {
                //% "Foreca"
                text: qsTrId("weather_settings-me-foreca")
                onClicked: weatherDataProvider.value = "foreca"
            }
            MenuItem {
                //% "Open Weather"
                text: qsTrId("weather_settings-me-open-weather")
                onClicked: weatherDataProvider.value = "open_weather"
            }
        }
    }

    TextField {
        id: providerApiKeyTextField
        visible: weatherDataProvider.value !== "foreca"
        text: weatherDataProvider.value.split(':')[1]
        placeholderText: "Enter App ID..."
        onTextChanged: {
            console.log("Entered App ID:", text)
            weatherDataProvider.value = 'open_weather:' + text;
        }
    }
}
