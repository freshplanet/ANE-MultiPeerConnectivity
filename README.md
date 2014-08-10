Air Native Extension for iOS Multipeer Connectivity (iOS7)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for managing the multipeer connections on iOS. It will detect all iOS7 nearby devices, connect to them and send a message to the connected ones. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Installation
---------

The ANE binary (AirBackgroundMusic.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


Usage
---------
The ANE comes in 2 parts:
- an assistant (to help being discovered)
- a discovery helper (to help discover)

To start the assistant, you need to call *AirMultiPeerConnectivity.getInstance().startAssistant(serviceType, peerName)*
To stop the assistant, you need to call *AirMultiPeerConnectivity.getInstance().stopAssistant()*

To start the discovery, you need to call *AirMultiPeerConnectivity.getInstance().startDiscovery(serviceType, peerName)*
To stop the discovery, you need to call *AirMultiPeerConnectivity.getInstance().stopDiscovery()*

The serviceType is a unique identifier, and should be the same for discovery and assistant. The peerName value is the device unique identifier.
For those two parameters, you can put whatever value you want.


Once the discovery starts, each peer found will dispatch a *AirMultiPeerConnectivityEvent.FOUND_PEER_EVENT* event
To register to this event, 
    
    AirMultiPeerConnectivity.getInstance().addEventListener(AirMultiPeerConnectivityEvent.FOUND_PEER_EVENT, onPeerFound);
    
    private function onPeerFound(event:AirMultiPeerConnectivityEvent):void
    {
        var peerName:String = event.peerName;
        // TODO
    }


Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/titi-us) (iOS).
It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).


Join the FreshPlanet team - GAME DEVELOPMENT in NYC
------

We are expanding our mobile engineering teams.

FreshPlanet is a NYC based mobile game development firm and we are looking for senior engineers to lead the development initiatives for one or more of our games/apps. We work in small teams (6-9) who have total product control.  These teams consist of mobile engineers, UI/UX designers and product experts.


Please contact Tom Cassidy (tcassidy@freshplanet.com) or apply at http://freshplanet.com/jobs/
