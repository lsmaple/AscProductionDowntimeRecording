var model = {};
var ascProdDowntimeRecordingApp = angular.module("ascProdDowntimeRecordingApp", ['ui.bootstrap'])
    .constant("downtimesListServicePathConst", "ProductionDowntimeListService.aspx")
    .constant("workCenterListServicePathConst", "WorkCenterListService.aspx")
    .constant("profileListServicePathConst", "ProfileListService.aspx")
    .constant("reasonCodeListServicePathConst", "ReasonCodeListService.aspx")
    .constant("profileChangeListServicePathConst", "ProfileChangeListService.aspx")
    .constant("unscheduledDowntimeListServicePathConst", "UnscheduledDowntimeListService.aspx")
    .constant("saveChangesServicePathConst", "SaveChangesService.aspx")
    .controller("AscProdDowntimeRecordingCtrl",
        function ($scope,
            $http,
            downtimesListServicePathConst,
            workCenterListServicePathConst,
            profileChangeListServicePathConst,
            unscheduledDowntimeListServicePathConst,
            profileListServicePathConst,
            reasonCodeListServicePathConst,
            saveChangesServicePathConst) {
        $scope.productionDowntimes = model;

        $scope.selectedStartTimes = [];
        $scope.profiles = [];
        $scope.dirty = false;
        $scope.selectedShiftStart = null;

        $scope.$watch("selectedShiftStart",
            function (newValue, oldValue) {
                if (newValue === oldValue) return;

                console.log("$watch: selectedDowntime.");

                $scope.selectedDowntime = null;

                for (var i = 0; i < $scope.productionDowntimes.length; i++) {
                    if ($scope.productionDowntimes[i].ShiftStartDate.toString() == newValue.toString()) {
                        $scope.selectedDowntime = angular.copy($scope.productionDowntimes[i]);
                        $scope.lastSelectedShiftStart = $scope.productionDowntimes[i].ShiftStartDate;
                    }
                }

                if ($scope.selectedDowntime == null) return;
        
                $scope.lastSelectedWorkCenter = $scope.selectedWorkCenter;

                getProfileChanges();

                getUnscheduledDowntimes();

                $scope.dtForm.$setPristine();
            });

        $scope.$watch("selectedWorkCenter",
            function (newValue, oldValue) {
                if (newValue === oldValue || ($scope.selectedDowntime && $scope.selectedDowntime.newRuntime)) return;

                console.log("$watch: selectedWorkCenter.");

                getRuntimes();

                $scope.dtForm.$setPristine();
            }
        );

        $http.get(workCenterListServicePathConst + '?rnd=' + new Date().getTime())
        .success(function (data) {
            $scope.workCenters = [];
            if (data.ListData) {
                $scope.workCenters = data.ListData;
                if (data.ListData.length > 0) {
                    $scope.selectedWorkCenter = $scope.workCenters[0];
                }
                console.log("work centers set");
            }
        })
        .error(function (err) {
            console.log("http err " + err);
        });

        $http.get(reasonCodeListServicePathConst + '?rnd=' + new Date().getTime())
        .success(function (data) {
            $scope.reasonCodes = [];
            if (data.ListData) {
                $scope.reasonCodes = data.ListData;
                console.log("reason codes set");
            }
        })
        .error(function (err) {
            console.log("http err " + err);
        });

        $scope.newRuntime = function () {
            $scope.lastSelectedWorkCenter = $scope.selectedWorkCenter;
            $scope.lastSelectedShiftStart = $scope.selectedShiftStart;
            $scope.selectedDowntime = {
                ID: -1,
                WorkCenter: $scope.selectedWorkCenter.WorkCenter,
                ScheduledShiftLength: 0,
                MachineUpTime: 0,
                PrimeLinearFeet: 0,
                CoilChanges: 0,
                ShiftStartDate: moment().startOf('hour').toDate(),
                profileChanges: [],
                unscheduledDowntime: [],
                newRuntime: true
            };
            $scope.dtForm.$setDirty();
            $scope.$digest();
        };

        $scope.saveRuntime = function () {
            $http.post(saveChangesServicePathConst, $scope.selectedDowntime)
                .success(function (data, status, headers, config) {
                    getRuntimes($scope.selectedDowntime.ShiftStartDate);
                    $scope.dtForm.$setPristine();
                })
                .error (function (data, status, headers, config) {
                    alert("Error on save.");
                });

            $scope.dtForm.$setPristine();
            $scope.$digest();
        };

        $scope.cancelRuntime = function () {
            $scope.selectedWorkCenter = $scope.lastSelectedWorkCenter;
            $scope.selectedShiftStart = $scope.lastSelectedShiftStart;
            $scope.selectedDowntime = {};
            for (var i = 0; i < $scope.productionDowntimes.length; i++) {
                if ($scope.selectedShiftStart == $scope.productionDowntimes[i].ShiftStartDate) {
                    $scope.selectedDowntime = angular.copy($scope.productionDowntimes[i]);
                }
            }
            $scope.lastSelectedWorkCenter = null;
            $scope.lastSelectedShiftStart = null;
            $scope.dtForm.$setPristine();
            $scope.$digest();
        };

        $scope.selectDowntime = function (downtime) {
            $scope.selectedDowntime = downtime;
        };

        $scope.open = function ($event) {
            $event.preventDefault();
            $event.stopPropagation();

            $scope.opened = true;
        };

        $scope.dateOptions = {
            formatYear: 'yy',
            startingDay: 0
        };

        $scope.addProfileChange = function () {
            var id = nextNewId($scope.selectedDowntime.profileChanges);
            var profileFrom = "";
            var profileTo = "";
            if ($scope.profiles.length > 0)
                profileFrom = profileTo = $scope.profiles[0].Title;
            if ($scope.selectedDowntime.profileChanges.length > 0)
                profileFrom = $scope.selectedDowntime.profileChanges[$scope.selectedDowntime.profileChanges.length - 1].ProfileTo;
            $scope.selectedDowntime.profileChanges.push({
                ID: id,
                ProfileFrom: profileFrom,
                ProfileTo: profileTo,
                status: "added"
            });

            // need to set the form as dirty
            $scope.dtForm.$setDirty();
            $scope.$digest();
        };

        $scope.deleteProfileChange = function (id) {
            for (var i = 0; i < $scope.selectedDowntime.profileChanges.length; i++) {
                if ($scope.selectedDowntime.profileChanges[i].ID === id) {
                    $scope.selectedDowntime.profileChanges[i].status = "deleted";
                    $scope.dtForm["profileChangesForm" + i].$setDirty();
                    break;
                }
            }
        };

        $scope.addUnscheduledDowntime = function () {
            var id = nextNewId($scope.selectedDowntime.unscheduledDowntime);
            var profileRunning = "";
            if ($scope.profiles.length > 0)
                profileRunning = profileTo = $scope.profiles[0].Title;
            if ($scope.selectedDowntime.profileChanges.length > 0)
                profileRunning = $scope.selectedDowntime.profileChanges[$scope.selectedDowntime.profileChanges.length - 1].ProfileTo;
            $scope.selectedDowntime.unscheduledDowntime.push({
                ID: id,
                ProfileRunning: profileRunning,
                DownTime: 0,
                ReasonCode: $scope.reasonCodes[0].Title,
                Details: "",
                status: "added"
            });

            // need to set the form as dirty
            $scope.dtForm.$setDirty();
            $scope.$digest();
        };

        $scope.deleteUnscheduledDowntime = function (id) {
            for (var i = 0; i < $scope.selectedDowntime.unscheduledDowntime.length; i++)
            {
                if ($scope.selectedDowntime.unscheduledDowntime[i].ID === id)
                {
                    $scope.selectedDowntime.unscheduledDowntime[i].status = "deleted";
                    $scope.dtForm["unscheduledDowntimesForm" + i].$setDirty();
                    break;
                }
            }
        };

        $scope.noneSelected = function () {
            return (!angular.isDefined($scope.selectedDowntime) ||
                    !angular.isDefined($scope.selectedDowntime.ID));
        };

        function nextNewId(data) {
            var minVal = 0;
            for (var i = 0; i < data.length; i++) {
                if (data[i].ID < minVal) minVal = data[i].ID;
            }
            minVal -= 1;
            return minVal;
        }

        function getMostRecentRuntime() {
            var mostRecentRuntime = null;
            for (var i = 0; i < $scope.productionDowntimes.length; i++) {
                if (mostRecentRuntime == null) {
                    mostRecentRuntime = $scope.productionDowntimes[i];
                }
                else {
                    if (mostRecentRuntime.ShiftStartDate < $scope.productionDowntimes[i].ShiftStartDate) {
                        mostRecentRuntime = $scope.productionDowntimes[i];
                    }
                }
            }
            return mostRecentRuntime;
        }

        function getRuntime(workCenter, shiftStartDate) {
            var runtime = null;
            for (var i = 0; i < $scope.productionDowntimes.length; i++) {
                if (shiftStartDate.toString() === $scope.productionDowntimes[i].ShiftStartDate.toString() &&
                    workCenter === $scope.productionDowntimes[i].WorkCenter) {
                    runtime = $scope.productionDowntimes[i];
                    break;
                }
            }
            return runtime;
        }

        function getRuntimes(shiftStartDate)
        {
            $scope.productionDowntimes = [];
            $scope.profiles = [];
            $scope.selectedDowntime = {};
            $scope.today = new Date();

            $http.get(downtimesListServicePathConst + '?WorkCenter=' + $scope.selectedWorkCenter.WorkCenter + '&rnd=' + new Date().getTime())
            .success(function (data) {
                if (data.ListData) {
                    for (var idx = 0; idx < data.ListData.length; idx++) {
                        var momentDate = moment(data.ListData[idx].ShiftStart);
                        data.ListData[idx].ShiftStartDate = momentDate.toDate();
                        data.ListData[idx].status = "unchanged";
                    }
                    $scope.productionDowntimes = data.ListData;
                    var runtime = null;
                    if (shiftStartDate)
                    {
                        runtime = getRuntime($scope.selectedWorkCenter.WorkCenter, shiftStartDate);
                    }
                    else
                    {
                        runtime = getMostRecentRuntime();
                    }
                    $scope.selectedDowntime = angular.copy(runtime);
                    $scope.selectedShiftStart = runtime.ShiftStartDate;
                    $scope.lastSelectedShiftStart = $scope.selectedShiftStart;
                    $scope.lastSelectedWorkCenter = $scope.selectedWorkCenter;
                    getProfileChanges();
                    getUnscheduledDowntimes();
                }
                console.log("downtimes set");
            })
            .error(function (err) {
                console.log("http err " + err);
            });

            $http.get(profileListServicePathConst + '?WorkCenter=' + $scope.selectedWorkCenter.WorkCenter + '&rnd=' + new Date().getTime())
            .success(function (data) {
                if (data.ListData) {
                    $scope.profiles = data.ListData;
                }
                console.log("profiles set");
            })
            .error(function (err) {
                console.log("http err " + err);
            });
        }

        function getProfileChanges() {
            $http.get(profileChangeListServicePathConst + '?WorkCenter=' + $scope.selectedWorkCenter.WorkCenter + '&ShiftStart=' + moment($scope.selectedDowntime.ShiftStartDate).format('MM/DD/YYYY HH:mm') + '&rnd=' + new Date().getTime())
                .success(function (data) {
                    $scope.selectedDowntime.profileChanges = [];
                    if (data.ListData) {
                        $scope.selectedDowntime.profileChanges = data.ListData;
                        for (var i = 0; i < $scope.selectedDowntime.profileChanges.length; i++) {
                            $scope.selectedDowntime.profileChanges[i].status = "unchanged";
                        }
                    }
                    console.log("profile changes set");
                })
                .error(function (err) {
                    console.log("http err " + err);
                });
        }

        function getUnscheduledDowntimes() {
            $http.get(unscheduledDowntimeListServicePathConst + '?WorkCenter=' + $scope.selectedWorkCenter.WorkCenter + '&ShiftStart=' + moment($scope.selectedDowntime.ShiftStartDate).format('MM/DD/YYYY HH:mm') + '&rnd=' + new Date().getTime())
            .success(function (data) {
                $scope.selectedDowntime.unscheduledDowntime = [];
                if (data.ListData) {
                    $scope.selectedDowntime.unscheduledDowntime = data.ListData;
                    for (var i = 0; i < $scope.selectedDowntime.unscheduledDowntime.length; i++) {
                        $scope.selectedDowntime.unscheduledDowntime[i].status = "unchanged";
                    }
                }
                console.log("unscheduled downtime set");
            })
            .error(function (err) {
                console.log("http err " + err);
            });
        }
    });