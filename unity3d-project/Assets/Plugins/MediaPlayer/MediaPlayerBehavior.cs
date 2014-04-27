using UnityEngine;
using System.Collections;

public class MediaPlayerBehavior : MonoBehaviour {
	
	IMediaPlayer			videoView;
	IMediaPlayerCallback	callback;
	
	#region Method
	
	public void Awake()
	{
		
		#if UNITY_ANDROID
		videoView = new IMediaPlayerAndroid();
		#elif UNITY_IPHONE
		videoView = new IMediaPlayerIOS();
		#else
		videoView = new IMediaPlayerNull();
		#endif
		
		callback = null;
	}

	public void Init(string title, string url) 
	{
		videoView.Init( name, title, url );
	}
	
	public void OnDestroy()
	{
		videoView.Term();
	}
	
	public void setCallback( IMediaPlayerCallback _callback )
	{
		callback = _callback;
	}
	
	public void onVideoFinish( string data )
	{
		if( callback != null )
		{
			callback.onVideoFinish( data );
		}
	}
	
	public void onVideoClose( string data )
	{
		if( callback != null )
		{
			callback.onVideoClose( data );
		}
	}
	
	#endregion
}
