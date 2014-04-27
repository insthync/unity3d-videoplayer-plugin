using UnityEngine;
using System.Collections;

#if UNITY_ANDROID
public class IMediaPlayerAndroid : IMediaPlayer {

	AndroidJavaObject	mediaPlayer		= null;
	
	public void Init( string name, string title, string url )
	{
		mediaPlayer = new AndroidJavaObject( "com.ittipon.unityvideoview.VideoViewPlugin" );
		SafeCall( "Init", name, title, url );
	}

	public void Term()
	{
		SafeCall( "Destroy" );
	}
	
	private void SafeCall( string method, params object[] args )
	{
		if( mediaPlayer != null )
		{
			mediaPlayer.Call( method, args );
		}
		else
		{
			Debug.LogError( "mediaPlayer is not created. you check is a call 'Init' method" );
		}
	}
}
#endif