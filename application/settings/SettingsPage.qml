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
        defaultValue: "open_weather"
    }
    ConfigurationValue {
       id: openWeatherProviderApiKey
       key: "/sailfish/weather/open_weather_provider_api_key"
       defaultValue: ""
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
            switch (weatherDataProvider.value) {
            case "foreca":
                currentIndex = 0
                break
            case "open_weather":
                currentIndex = 1
                break
            default:
                console.log("WeatherSettings: Invalid weather providervalue", weatherDataProvider.value)
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
                onClicked: weatherDataProvider.value = "open-weather"
            }
        }
    }

    TextField {
        id: providerApiKeyTextField
        visible: weatherDataProvider.value !== "foreca"
        placeholderText: "Enter Api key..."
        onAccepted: {
            console.log("Entered Api key:", text)
            switch (weatherDataProvider.value) {
            case 'open-weather':
                openWeatherProviderApiKey.value = text
                break;
            default:
                console.log('Weather Provider doesn\'t support API Key')
            }

        }
    }
}
