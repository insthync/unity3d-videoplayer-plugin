using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

#if UNITY_IPHONE
public class IMediaPlayerIOS : IMediaPlayer {
	
	private IntPtr instance;
	
	#region Interface Method
	public void Init( string name, string title, string url )
	{
		instance = _VideoViewPlugin_Init( name, title, url );
	}
	public void Term()
	{
		_VideoViewPlugin_Destroy( instance );
	}
	
	#endregion
	
	#region Native Access Method
	[DllImport("__Internal")]
	private static extern IntPtr _VideoViewPlugin_Init(string name, string title, string url);
	
	[DllImport("__Internal")]
	private static extern int _VideoViewPlugin_Destroy(IntPtr instance);
	
	#endregion
}
#endif