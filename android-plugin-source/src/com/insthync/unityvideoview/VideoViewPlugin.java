package com.insthync.unityvideoview;
import java.io.IOException;

import com.unity3d.player.UnityPlayer;

import android.app.Activity;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.FrameLayout;
import android.widget.MediaController;
import android.widget.RelativeLayout;
import android.widget.VideoView;


public class VideoViewPlugin implements MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener, MediaPlayer.OnErrorListener, SurfaceHolder.Callback {
	private static final String TAG = "UnityMediaPlayer";
	private static RelativeLayout layout = null;
	private VideoView videoView;
	private AdsMediaController mediaController;
	private String videoURL = "";
	private String gameObject = "";
	private int currentVideoPosition = 0;
	public void Init(final String gameObject, final String title, final String videoURL)
	{
		this.gameObject = gameObject;
		this.videoURL = videoURL;
		final Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			
			public void run() {
				Destroy();
				
				if (layout == null) {
					layout = new RelativeLayout(a);
					RelativeLayout.LayoutParams layoutParams;
					layoutParams = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
					a.addContentView(layout, layoutParams);
					layout.setBackgroundColor(Color.BLACK);
				}
				layout.setVisibility(View.VISIBLE);
				layout.setFocusable(true);
				layout.setFocusableInTouchMode(true);
				
				videoView = new VideoView(a);
				videoView.setVideoPath(videoURL);
				videoView.setOnCompletionListener(VideoViewPlugin.this);
				videoView.setOnPreparedListener(VideoViewPlugin.this);
				videoView.setOnErrorListener(VideoViewPlugin.this);
				videoView.setZOrderMediaOverlay(true);
				if (mediaController == null) {
					mediaController = new AdsMediaController(a);
				}
				mediaController.setTitle(title);
				mediaController.setCloseListener(closeListener);
				mediaController.setMediaPlayer(videoView);
				videoView.setMediaController(mediaController);
				
				RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
				layoutParams.addRule(RelativeLayout.CENTER_IN_PARENT, -1);
				videoView.setLayoutParams(layoutParams);
				
				layout.addView(videoView);
				
				videoView.getHolder().addCallback(VideoViewPlugin.this);
			}
		});
	}

    private View.OnClickListener closeListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			UnityPlayer.UnitySendMessage( gameObject , "onVideoClose", "" );
		    Destroy();
		}
    };
    
	@Override
	public void onCompletion(MediaPlayer mediaPlayer) {
	    Log.d(TAG, "onCompletion called");
		UnityPlayer.UnitySendMessage( gameObject , "onVideoFinish", "" );
	    Destroy();
	}
	
	@Override
	public void onPrepared(MediaPlayer mediaPlayer) {
	    Log.d(TAG, "onPrepared called");
	    mediaPlayer.start();
	    if (currentVideoPosition > 0) {
	    	mediaPlayer.seekTo(currentVideoPosition);
	    } else {
	    	mediaPlayer.seekTo(0);
	    }
	}
	
	@Override
	public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
		// TODO Auto-generated method stub
	    Log.d(TAG, "onError called");
	    Destroy();
		return false;
	}
	
	public void Destroy()
	{
		Activity a = UnityPlayer.currentActivity;
		a.runOnUiThread(new Runnable() {
			public void run() {
				if (videoView != null) {
					videoView.stopPlayback();
					layout.removeView(videoView);
					videoView = null;
				}
				if (layout != null) {
					layout.setFocusable(false);
					layout.setFocusableInTouchMode(false);
					layout.setVisibility(View.GONE);
				}
			    currentVideoPosition = 0;
			}
		});
	}
	
	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
	    Log.d(TAG, "surfaceChanged called");
	}
	
	@Override
	public void surfaceCreated(SurfaceHolder holder) {
	    Log.d(TAG, "surfaceCreated called");
	}
	
	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
	    Log.d(TAG, "surfaceDestroyed called");
	    currentVideoPosition = videoView.getCurrentPosition();
	    videoView.stopPlayback();
		videoView.seekTo(currentVideoPosition);
	}
}
