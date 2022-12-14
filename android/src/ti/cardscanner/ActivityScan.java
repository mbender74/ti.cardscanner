/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * TiDev Titanium Mobile
 * Copyright TiDev, Inc. 04/07/2022-Present
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package ti.cardscanner;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.titanium.TiC;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiCompositeLayout;
import org.appcelerator.titanium.view.TiCompositeLayout.LayoutArrangement;
import org.appcelerator.titanium.view.TiUIView;
import org.appcelerator.titanium.TiApplication;
import android.os.Bundle;
import android.widget.FrameLayout;
import android.view.ViewGroup.LayoutParams;

import android.app.Activity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentTransaction;
import androidx.fragment.app.FragmentActivity;
import android.content.res.Resources;
import android.widget.RelativeLayout;
import org.appcelerator.titanium.proxy.TiViewProxy;
import org.appcelerator.titanium.view.TiUIView;
import android.view.View;
import android.view.ViewGroup;

import android.view.LayoutInflater;
import androidx.constraintlayout.widget.ConstraintLayout;
import java.util.HashMap;

public class ActivityScan extends FragmentActivity
 {

	private static final String LCAT = "ActivityScan";

	KrollFunction callback = null;
	private static ActivityScan _instance;
	private View overlayView;
	private RecognitionFragment fragment;

	private RelativeLayout viewWrapper;

	public static ActivityScan getInstance()
	{
		return _instance;
	}


	public void torch()
	{
		if (fragment != null)
		{
			fragment.switchTorch();
		}
	}



	@SuppressWarnings("rawtypes")

	@Override
	 public void onCreate(Bundle savedInstanceState) {
	   super.onCreate(savedInstanceState);


 	    //Log.e("++++++++++++++++++++++  ActivityScan", "onCreate");
		_instance = this;


		final Activity activity = TiApplication.getAppCurrentActivity();
		final String packageName = activity.getPackageName();
      	final Resources resources = activity.getResources();
		final int resId_viewHolder = resources.getIdentifier("mainlayout", "layout", packageName);
		// final int resId_fragment = resources.getIdentifier("fragment_recognition", "layout", packageName);

    	
        int id_fragmentHolder = resources.getIdentifier("fragmentHolder", "id", packageName);

		LayoutInflater inflater = LayoutInflater.from(activity);

		viewWrapper = (RelativeLayout) inflater.inflate(resId_viewHolder, null);


	    setContentView(viewWrapper);



 	  	fragment = new RecognitionFragment();

	     if (savedInstanceState == null){
	     		getSupportFragmentManager().beginTransaction()
	             .replace(id_fragmentHolder, fragment).commit();
	     }


        TiViewProxy viewproxy = TiCardscannerModule.getInstance().getOverlayView();
        if (viewproxy != null){

			//Log.w(LCAT, "++++++++++++++++++++++++++++  setOverlayView");

			overlayView = viewproxy.getOrCreateView().getNativeView();

		     if (overlayView != null){
				ViewGroup parent = (ViewGroup) overlayView.getParent();

				if (parent != null) {
					parent.removeView(overlayView);
				}

	  	 	    //Log.e("++++++++++++++++++++++  ActivityScan", "overlayView");

	   			viewWrapper.addView(overlayView,new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
		     }
        }

	 }
}
