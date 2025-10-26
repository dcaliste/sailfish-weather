// SPDX-FileCopyrightText: 2013 - 2023 Jolla Ltd.
// SPDX-FileCopyrightText: 2024 - 2025 Jolla Mobile Ltd
//
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property string filter
    property alias status: model.status

    onFilterChanged: if (filter.length === 0) clear()

    function reload() {
        model.reload()
    }

    readonly property WeatherRequest model: WeatherRequest {
        id: model

        property string language: {
            var locale = Qt.locale().name
            if (locale === "zh_CN" || locale === "zh_TW") {
                return locale
            } else {
                return locale.split("_")[0]
            }
        }

        source: filter.length > 0 ? "https://nominatim.openstreetmap.org/search?format=json&accept-language=" + language + "&city=" + filter.toLowerCase() : ""
        onRequestFinished: {
            var locations = result
            if (result.length === 0 || locations === undefined) {
                status = Weather.Error
            } else {
                while (root.count > locations.length) {
                    root.remove(locations.length)
                }
                for (var i = 0; i < locations.length; i++) {
                    var location = locations[i]
                    location.id = location.place_id
                    location.country = location.display_name
                    if (i < root.count) {
                        root.set(i, location)
                    } else {
                        root.append(location)
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error || status === Weather.Unauthorized) {
                root.clear()
                console.log("LocationsModel - location search failed with query string", filter)
            }
        }
    }
}
