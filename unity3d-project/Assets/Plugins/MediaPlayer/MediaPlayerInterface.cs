using UnityEngine;
using System.Collections;

public interface IMediaPlayer
{
	
	void Init( string name, string title, string url );
	void Term();
	
}

public interface IMediaPlayerCallback
{
	void onVideoFinish( string data );
	void onVideoClose( string data );
}
