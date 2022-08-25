
var ANDROID = (Ti.Platform.osname === 'android');
var cardScannerModule = require('ti.cardscanner');

if (ANDROID){
    var PlayServices = require('ti.playservices');
    var playServicesAvailable = PlayServices.makeGooglePlayServicesAvailable(function (e){});     
}


cardScannerModule.addEventListener("close",function(){
    console.log("scanner closed");
});

var cardScanCallback = function(e){
    console.log("");
    console.log("+++++++++++++++++++++++++");
    console.log("cardScanCallback RESULT "+JSON.stringify(e));
    console.log("+++++++++++++++++++++++++");
    console.log("");
};


var overlayContainer = Ti.UI.createView({
    left:0,
    right:0,
    top:0,
    bottom:0,
    width:Ti.UI.FILL,
    height:Ti.UI.FILL
});

var cancelButton = Ti.UI.createView({
    right:20,
    top:20,
    backgroundColor:'red',
    width:44,
    height:44,
    borderRadius:22
});

var torchButton = Ti.UI.createView({
    left:20,
    top:20,
    backgroundColor:'gray',
    width:44,
    height:44,
    borderRadius:22
});

overlayContainer.add(torchButton);
overlayContainer.add(cancelButton);

cancelButton.addEventListener("click",function(){
    console.log("cancelButton clicked");
    cardScannerModule.close({animated:true});
});

torchButton.addEventListener("click",function(){
    console.log("torchButton clicked");
    cardScannerModule.torch();
});


/**
 * Create a new `Ti.UI.TabGroup`.
 */
var tabGroup = Ti.UI.createTabGroup();

/**
 * Add the two created tabs to the tabGroup object.
 */
tabGroup.addTab(createTab("Tab 1", "touch me to open scanner 1", "assets/images/tab1.png"));
tabGroup.addTab(createTab("Tab 2", "touch me to open scanner 2", "assets/images/tab2.png"));

/**
 * Open the tabGroup
 */
tabGroup.open();

/**
 * Creates a new Tab and configures it.
 *
 * @param  {String} title The title used in the `Ti.UI.Tab` and it's included `Ti.UI.Window`
 * @param  {String} message The title displayed in the `Ti.UI.Label`
 * @return {String} icon The icon used in the `Ti.UI.Tab`
 */
function createTab(title, message, icon) {
    var win = Ti.UI.createWindow({
        title: title,
        backgroundColor: '#fff'
    });

 


    var label = Ti.UI.createLabel({
        text: message,
        color: "#333",
        font: {
            fontSize: 20
        }
    });

        label.addEventListener("click",function(){
            cardScannerModule.scan({
                animated:true,
                modal:true,
                overlayView:overlayContainer,
                callback:cardScanCallback
            });
        });
    
    win.add(label);

    var tab = Ti.UI.createTab({
        title: title,
        icon: icon,
        window: win
    });

    return tab;
}
