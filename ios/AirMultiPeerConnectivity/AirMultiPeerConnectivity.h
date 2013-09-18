//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

#import "FlashRuntimeExtensions.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface AirMultiPeerConnectivity : NSObject <MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate>

+ (AirMultiPeerConnectivity *)sharedInstance;
+ (void)dispatchEvent:(NSString*)eventName withInfo:(NSString*)info;
+ (void)log:(NSString*)message;

@end

DEFINE_ANE_FUNCTION(isSupported);
DEFINE_ANE_FUNCTION(startAssistant);
DEFINE_ANE_FUNCTION(stopAssistant);
DEFINE_ANE_FUNCTION(sendMessage);
DEFINE_ANE_FUNCTION(startBrowsing);
DEFINE_ANE_FUNCTION(stopBrowsing);
DEFINE_ANE_FUNCTION(startDiscovery);
DEFINE_ANE_FUNCTION(stopDiscovery);
DEFINE_ANE_FUNCTION(stopCurrentSession);

void AirMultiPeerConnectivityExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);

void AirMultiPeerConnectivityExtFinalizer(void* extData);
void AirMultiPeerConnectivityContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirMultiPeerConnectivityContextFinalizer(FREContext ctx);


