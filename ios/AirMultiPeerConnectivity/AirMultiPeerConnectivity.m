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

#import "AirMultiPeerConnectivity.h"

FREContext AirMultiPeerConnectivityCtx = nil;

@interface AirMultiPeerConnectivity ()
{
    MCSession *currentSession;
    MCAdvertiserAssistant *assistant;
    MCBrowserViewController *browser;
    MCNearbyServiceBrowser *serviceBrowser;
}

@property(nonatomic, retain) MCSession *currentSession;
@property(nonatomic, retain) MCAdvertiserAssistant *assistant;
@property(nonatomic, retain) MCBrowserViewController *browser;
@property(nonatomic, retain) MCNearbyServiceBrowser *serviceBrowser;

- (void)startAssistantWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName;
- (void)stopAssistant;
- (void)sendMessage:(NSString *)message;
- (void)startBrowsingWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName;
- (void)stopBrowsing;
- (void)startDiscoveryWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName;
- (void)stopDiscovery;
- (void)stopSession;
- (UIViewController *)rootViewController;

@end

@implementation AirMultiPeerConnectivity
@synthesize currentSession, assistant, browser, serviceBrowser;

#pragma mark - Singleton

static AirMultiPeerConnectivity *sharedInstance = nil;

+ (AirMultiPeerConnectivity *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }

    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}

- (void)startAssistantWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName
{
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:peerIdName];
    
    // assistant
    self.currentSession = [[MCSession alloc] initWithPeer:peerId];
    self.currentSession.delegate = self;
    
    self.assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:serviceType discoveryInfo:nil session:self.currentSession];
    if (self.assistant)
    {
        self.assistant.delegate = self;
        [self.assistant start];
    } else
    {
        [AirMultiPeerConnectivity log:@"Cant start the assistant"];
    }

}

- (void)stopAssistant
{
    if (assistant)
    {
        [self.assistant stop];
    }
}

- (void)sendMessage:(NSString *)message
{
    if (currentSession)
    {
        NSArray *peerIds = [self.currentSession connectedPeers];
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        [self.currentSession sendData:data toPeers:peerIds withMode:MCSessionSendDataReliable error:&error];
    }
}

- (void)startBrowsingWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName
{
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:peerIdName];
    
    // browser
    self.currentSession = [[MCSession alloc] initWithPeer:peerId];
    self.currentSession.delegate = self;
    
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:self.currentSession];
    if (self.browser)
    {
        self.browser.delegate = self;
        [[self rootViewController] presentViewController:browser animated:YES completion:nil];
    } else
    {
        [AirMultiPeerConnectivity log:@"Cant start the browser"];
    }
}

- (void)stopBrowsing
{
    if (browser)
    {
        [self.browser dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)startDiscoveryWith:(NSString *)serviceType andPeerId:(NSString *)peerIdName
{
    MCPeerID *peerId = [[MCPeerID alloc] initWithDisplayName:peerIdName];
    
    // nearby browser
    self.serviceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerId serviceType:serviceType];
    if (self.serviceBrowser)
    {
        self.serviceBrowser.delegate = self;
        [self.serviceBrowser startBrowsingForPeers];
    } else
    {
        [AirMultiPeerConnectivity log:@"Cant start the discovery"];
    }
}

- (void)stopDiscovery
{
    if (serviceBrowser)
    {
        [self.serviceBrowser stopBrowsingForPeers];
    }
}


- (void)stopSession
{
    if (currentSession)
    {
        [self.currentSession disconnect];
    }
}

+ (void)dispatchEvent:(NSString *)eventName withInfo:(NSString *)info
{
    FREDispatchStatusEventAsync(AirMultiPeerConnectivityCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[info UTF8String]);
}

+ (void)log:(NSString *)message
{
    NSLog(@"%@", message);
    [AirMultiPeerConnectivity dispatchEvent:@"LOGGING" withInfo:message];
}

- (UIViewController *)rootViewController
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}


#pragma mark - MCBrowserViewController

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCNearbyServiceBrowser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    [AirMultiPeerConnectivity dispatchEvent:@"FOUND_PEER_EVENT" withInfo:peerID.displayName];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    [AirMultiPeerConnectivity dispatchEvent:@"LOST_PEER_EVENT" withInfo:peerID.displayName];
}

#pragma mark - MCSession Delegate


// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    [AirMultiPeerConnectivity log:@"session did changed"];
    if (state == MCSessionStateConnected)
    {
        [AirMultiPeerConnectivity dispatchEvent:@"CONNECTED_EVENT" withInfo:peerID.displayName];
    } else if (state == MCSessionStateNotConnected)
    {
        [AirMultiPeerConnectivity dispatchEvent:@"DISCONNECTED_EVENT" withInfo:peerID.displayName];
    }
    
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    [AirMultiPeerConnectivity dispatchEvent:@"RECEIVED_MSG_EVENT" withInfo:dataString];
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    [AirMultiPeerConnectivity log:@"session did receive stream"];
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    [AirMultiPeerConnectivity log:@"session did started receiving resource"];
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    [AirMultiPeerConnectivity log:@"session did finished receiving resource"];
}


@end


#pragma mark - C interface
/**
 * Check that multipeer is supported on the current device
 */
DEFINE_ANE_FUNCTION(isSupported)
{
    uint32_t boolean;
    if ([MCBrowserViewController class])
    {
        boolean = YES;
    } else
    {
        boolean = NO;
    }

    FREObject retBool = nil;
    FRENewObjectFromBool(boolean, &retBool);

    return retBool;
}


DEFINE_ANE_FUNCTION(startAssistant)
{
    uint32_t stringLength;
    
    const uint8_t *serviceTypeString;
    NSString *serviceType = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &serviceTypeString) == FRE_OK)
    {
        serviceType = [NSString stringWithUTF8String:(char *)serviceTypeString];
    }
    
    const uint8_t *peerIdString;
    NSString *peerId = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &peerIdString) == FRE_OK)
    {
        peerId = [NSString stringWithUTF8String:(char *)peerIdString];
    }
    
    if (peerId && serviceType)
    {
        [[AirMultiPeerConnectivity sharedInstance] startAssistantWith:serviceType andPeerId:peerId];
    } else
    {
        NSLog(@"no peerId or no service type");
    }
    return nil;
}

DEFINE_ANE_FUNCTION(stopAssistant)
{
    [[AirMultiPeerConnectivity sharedInstance] stopAssistant];
    return nil;
}

DEFINE_ANE_FUNCTION(sendMessage)
{
    uint32_t stringLength;
    
    const uint8_t *messageString;
    NSString *message = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &messageString) == FRE_OK)
    {
        message = [NSString stringWithUTF8String:(char *)messageString];
    }
    
    
    if (message)
    {
        [[AirMultiPeerConnectivity sharedInstance] sendMessage:message];
    } else
    {
        NSLog(@"no message");
    }
    return nil;
}


DEFINE_ANE_FUNCTION(startBrowsing)
{
    uint32_t stringLength;
    
    const uint8_t *serviceTypeString;
    NSString *serviceType = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &serviceTypeString) == FRE_OK)
    {
        serviceType = [NSString stringWithUTF8String:(char *)serviceTypeString];
    }
    
    const uint8_t *peerIdString;
    NSString *peerId = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &peerIdString) == FRE_OK)
    {
        peerId = [NSString stringWithUTF8String:(char *)peerIdString];
    }
    
    if (peerId && serviceType)
    {
        [[AirMultiPeerConnectivity sharedInstance] startBrowsingWith:serviceType andPeerId:peerId];
    } else
    {
        NSLog(@"no peerId or no service type");
    }
    return nil;
}

DEFINE_ANE_FUNCTION(stopBrowsing)
{
    [[AirMultiPeerConnectivity sharedInstance] stopBrowsing];
    return nil;
}

DEFINE_ANE_FUNCTION(startDiscovery)
{
    uint32_t stringLength;
    
    const uint8_t *serviceTypeString;
    NSString *serviceType = nil;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &serviceTypeString) == FRE_OK)
    {
        serviceType = [NSString stringWithUTF8String:(char *)serviceTypeString];
    }
    
    const uint8_t *peerIdString;
    NSString *peerId = nil;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &peerIdString) == FRE_OK)
    {
        peerId = [NSString stringWithUTF8String:(char *)peerIdString];
    }
    
    if (peerId && serviceType)
    {
        [[AirMultiPeerConnectivity sharedInstance] startDiscoveryWith:serviceType andPeerId:peerId];
    } else
    {
        NSLog(@"no peerId or no service type");
    }
    return nil;
}

DEFINE_ANE_FUNCTION(stopDiscovery)
{
    [[AirMultiPeerConnectivity sharedInstance] stopDiscovery];
    return nil;
}

DEFINE_ANE_FUNCTION(stopCurrentSession)
{
    [[AirMultiPeerConnectivity sharedInstance] stopSession];
    return nil;
}


#pragma mark - ANE setup

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void AirMultiPeerConnectivityContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{

    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     * As a sample, the function isSupported is being provided.
     */
    *numFunctionsToTest = 9;

    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &isSupported;
    
    func[1].name = (const uint8_t*) "startAssistant";
    func[1].functionData = NULL;
    func[1].function = &startAssistant;

    func[2].name = (const uint8_t*) "stopAssistant";
    func[2].functionData = NULL;
    func[2].function = &stopAssistant;

    func[3].name = (const uint8_t*) "sendMessage";
    func[3].functionData = NULL;
    func[3].function = &sendMessage;

    func[4].name = (const uint8_t*) "startBrowsing";
    func[4].functionData = NULL;
    func[4].function = &startBrowsing;

    func[5].name = (const uint8_t*) "stopBrowsing";
    func[5].functionData = NULL;
    func[5].function = &stopBrowsing;
    
    func[6].name = (const uint8_t*) "startDiscovery";
    func[6].functionData = NULL;
    func[6].function = &startDiscovery;

    func[7].name = (const uint8_t*) "stopDiscovery";
    func[7].functionData = NULL;
    func[7].function = &stopDiscovery;
    
    func[8].name = (const uint8_t*) "stopSession";
    func[8].functionData = NULL;
    func[8].function = &stopCurrentSession;

    *functionsToSet = func;

    AirMultiPeerConnectivityCtx = ctx;

}

void AirMultiPeerConnectivityExtFinalizer(void* extData) {}

void AirMultiPeerConnectivityContextFinalizer(FREContext ctx) {}

void AirMultiPeerConnectivityExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirMultiPeerConnectivityContextInitializer;
    *ctxFinalizerToSet = &AirMultiPeerConnectivityContextFinalizer;
}

