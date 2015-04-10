var model = {};
var ascProdDowntimeRecordingApp = angular.module("ascProdDowntimeRecordingApp")
    .filter("reasonDescription", function () {
        return function (reasonCode, codeInfo) {
            var result = "";
            if (angular.isArray(codeInfo) && angular.isString(reasonCode)) {
                for (var i = 0; i < codeInfo.length; i++) {
                    if (codeInfo[i].Title == reasonCode) {
                        result = codeInfo[i].Description;
                        break;
                    }
                }
            }
            return result;
        }
    })
    .filter("removeDeleted", function () {
        return function (items) {
            var results = [];
            if (angular.isArray(items)) {
                for (var i = 0; i < items.length; i++) {
                    if (items[i].status && items[i].status !== "deleted") {
                        results.push(items[i]);
                    }
                }
            }
            else
            {
                results = items;
            }
            return results;
        }
    });