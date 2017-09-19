var exec = require("cordova/exec");

module.exports = {
    checkStatus: function (port, callback) {
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'checkStatus', [port]);
    },
    checkStatus: function (port, callback) {
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'checkStatus', [port]);
    },
    portDiscovery: function (type, callback) {
        type = type || 'All';
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'portDiscovery', [type]);
    },
    printMobile: function(name, address, phone, date, barcode, callback){
           exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'printMobile', [name, address, phone, date, barcode]);

    },
    printReceipt: function (port, receipt, callback) {
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'printReceipt', [port, receipt]);
    },
    printImage: function (port, receipt, callback) {
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'printImage', [port, receipt]);
    },
    openCashDrawer: function (port, callback) {
        exec(function (result) {
                callback(null, result)
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'openCashDrawer', [port]);
    },
    connect: function (port, callback) {
        var connected = false;
        exec(function (result) {
                //On initial connection - fire callback, otherwise fire a window event
                if (!connected) {
                    callback(null, result);
                    connected = true;
                } else {
                    //This event will be to notify of events like barcode scans
                    cordova.fireWindowEvent("starIOPluginData", result);
                }
            },
            function (error) {
                callback(error)
            }, 'StarIOPlugin', 'connect', [port]);
    }
};
