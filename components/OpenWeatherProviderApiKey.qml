// SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause
//
// @author Anton Turko <turok@duck.com>

pragma Singleton
import QtQuick 2.2
import Nemo.Configuration 1.0

ConfigurationValue {
   id: openWeatherProviderApiKey
   key: "/sailfish/weather/open_weather_provider_api_key"
   defaultValue: ""
}

