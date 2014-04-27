using UnityEngine;
using System.Collections;

class CallBackTest : IMediaPlayerCallback {
	public void onVideoFinish( string data ) {
		Debug.Log("Video played, data: " + data);
	}
	public void onVideoClose( string data )  {
		Debug.Log("Video closed, data: " + data);
	}
}

public class MediaPlayerTest : MonoBehaviour {
	
	CallBackTest m_callback;
	
	// Use this for initialization
	void Start () {
		
		m_callback = new CallBackTest();
		MediaPlayerBehavior player = GetComponent<MediaPlayerBehavior>();
		
		if( player != null )
		{
			player.Init( "Test title", "http://video-js.zencoder.com/oceans-clip.mp4");
			player.setCallback( m_callback );
		}
	}
}
