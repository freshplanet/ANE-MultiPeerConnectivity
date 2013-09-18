package com.freshplanet.ane
{
	import flash.events.Event;
	
	public class AirMultiPeerConnectivityEvent extends Event
	{
		public static const CONNECTED_TO_PEER_EVENT:String = "CONNECTED_EVENT";
		public static const DISCONNECTED_FROM_PEER_EVENT:String = "DISCONNECTED_EVENT";
		public static const RECEIVED_MSG_EVENT:String = "RECEIVED_MSG_EVENT";
		public static const FOUND_PEER_EVENT:String = "FOUND_PEER_EVENT";
		public static const LOST_PEER_EVENT:String = "LOST_PEER_EVENT";

		private var _data:String;
		
		public function AirMultiPeerConnectivityEvent(type:String, data:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			super(type, bubbles, cancelable);
		}
		
		public function get peerName():String
		{
			return _data;
		}
		
		public function get message():String
		{
			return _data;
		}
		
	}
}