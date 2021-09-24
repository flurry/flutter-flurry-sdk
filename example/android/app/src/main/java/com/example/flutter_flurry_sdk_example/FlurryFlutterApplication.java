/*
 * Copyright 2021, Yahoo Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.flutter_flurry_sdk_example;

import android.util.Log;

import com.flurry.android.flutter.FlurryFlutterPlugin;
import com.flurry.android.marketing.FlurryMarketingOptions;

import io.flutter.app.FlutterApplication;

public class FlurryFlutterApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();

        // Optional user's native `FlurryMarketingOptions` or `FlurryMessagingListener`.
        FlurryMarketingOptions messagingOptions = new FlurryMarketingOptions.Builder()
                .setupMessagingWithAutoIntegration()
                .withDefaultNotificationIconResourceId(R.mipmap.ic_launcher)
                // Define yours if needed
                // .withDefaultNotificationChannelId(NOTIFICATION_CHANNEL_ID)
                // .withDefaultNotificationIconAccentColor(getResources().getColor(R.color.colorPrimary))
                // .withFlurryMessagingListener(messagingListener)
                .build();

        // To enable Flurry Push for Android, please duplicate Builder setup in your FlutterApplication class.
        new FlurryFlutterPlugin.Builder()
                .withLogEnabled(true)
                .withLogLevel(Log.VERBOSE)
                .withMessaging(true, messagingOptions)
                .build(this, "C9R699NJWSMJVPQWJ273");
    }

}
