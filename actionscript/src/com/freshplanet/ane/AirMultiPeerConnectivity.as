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

package com.freshplanet.ane
{
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirMultiPeerConnectivity extends EventDispatcher
	{
		private static var _instance:AirMultiPeerConnectivity;
		
		private var extCtx:ExtensionContext = null;
				
		public function AirMultiPeerConnectivity()
		{
			if (!_instance)
			{
				extCtx = ExtensionContext.createExtensionContext("com.freshplanet.ane.AirMultiPeerConnectivity", null);
				if (extCtx != null)
				{
					extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				} 
				else
				{
					trace('[AirMultiPeerConnectivity] Error - Extension Context is null.');
				}
				_instance = this;
			}
			else
			{
				throw Error('This is a singleton, use getInstance(), do not call the constructor directly.');
			}
		}
		
		public static function getInstance():AirMultiPeerConnectivity
		{
			return _instance ? _instance : new AirMultiPeerConnectivity();
		}

		private var _isInitialized:Boolean;
		private var _isSupported:Boolean;
		
		/**
		 * Is this Native Extension supported?
		 */		
		public function isSupported():Boolean
		{
			if ( Capabilities.manufacturer.indexOf("iOS") > -1 )
			{
				if (!_isInitialized)
				{
					_isSupported = extCtx.call('isSupported') as Boolean;
					_isInitialized = true;
				}
			}
			return _isSupported;
		}
		
		public function startAssistant(serviceType:String, peerName:String):void
		{
			if (isSupported())
			{
				extCtx.call('startAssistant', serviceType, peerName);
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}
		
		public function stopAssistant():void
		{
			if (isSupported())
			{
				extCtx.call('stopAssistant');
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}

		public function sendMessage(message:String):void
		{
			if (isSupported())
			{
				extCtx.call('sendMessage', message);
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}
		
		public function startBrowsing(serviceType:String, peerName:String):void
		{
			if (isSupported())
			{
				extCtx.call('startBrowsing', serviceType, peerName);
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}
		
		public function stopBrowsing():void
		{
			if (isSupported())
			{
				extCtx.call('stopBrowsing');
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}

		public function startDiscovery(serviceType:String, peerName:String):void
		{
			if (isSupported())
			{
				extCtx.call('startDiscovery', serviceType, peerName);
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}
		
		public function stopDiscovery():void
		{
			if (isSupported())
			{
				extCtx.call('stopDiscovery');
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}

		public function stopSession():void
		{
			if (isSupported())
			{
				extCtx.call('stopSession');
			} else
			{
				trace('[AirMultiPeerConnectivity]', 'not supported');
			}
		}

		
		
		/**
		 * Status events allow the native part of the ANE to communicate with the ActionScript part.
		 * We use event.code to represent the type of event, and event.level to carry the data.
		 */
		private function onStatus( event : StatusEvent ) : void
		{
			var e:AirMultiPeerConnectivityEvent;
			switch(event.code)
			{
				case AirMultiPeerConnectivityEvent.CONNECTED_TO_PEER_EVENT:
				case AirMultiPeerConnectivityEvent.DISCONNECTED_FROM_PEER_EVENT:
				case AirMultiPeerConnectivityEvent.RECEIVED_MSG_EVENT:
				case AirMultiPeerConnectivityEvent.FOUND_PEER_EVENT:
				case AirMultiPeerConnectivityEvent.LOST_PEER_EVENT:
					e = new AirMultiPeerConnectivityEvent(event.code, event.level);
					break;
				case "LOGGING":
					trace('[AirMultiPeerConnectivity] ', event.level);
					break;
				default:
			}
			
			if (e)
			{
				this.dispatchEvent(e);
			}
		}
	}
}
