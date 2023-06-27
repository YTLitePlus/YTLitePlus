# YTUHD

Unlock 1440p (2K) and 2160p (4K) resolutions in iOS YouTube app.

## Backstory

For a few years, YouTube has been testing 2K/4K resolutions on iOS as A/B (Alpha/Beta testing). The first group of users will see 2K/4K options while the other won't.
There are certain prerequisites for those options to show; (1) Whether a device support VP9 video decoding (which implies on Apple's end to be at least on iOS 14) and
(2) Whether YouTube decides on their end to include those options for that particular device.
YTUHD attemps to bypass those restrictions for all 64-bit devices running iOS 11 or higher, as the performance points of those devices are at most reasonable to be able to keep up with 2K/4K, at least, optimistically.

## VP9

Hardware accelerated VP9 decoder is technically added as of iOS 14 and YouTube has been utilizing it through a private entitlement `com.apple.coremedia.allow-alternate-video-decoder-selection` (All apps are equal is a lie).
This decoder handles the resolutions up to 4K, although not all devices that can run iOS 14 get this decoder. iPhone SE (1st gen) is one example that hardware VP9 decoder is entirely absent from the firmware.

Also, for those old devices they don't get `AppleAVD` driver which is essential for VP9 decoding to work. Such attempt to load VP9 decoder (inside `AppleAVD` driver) from `/System/Library/VideoDecoders/AVD.videodecoder` (provided that you can extract that from dyld_shared_cache of a new device) will result in `AVDRegister - AppleAVDCheckPlatform() returned FALSE`.

## Server ABR

If you look at the source code, there is an enforcement to not use server ABR. The author has yet to figure out what ABR stands for but its purpose is to fetch the available formats (resolutions) of a video.
When the flag is set to true, it's entirely up to YouTube server to respond to YouTube app of the video formats the user can be served.
YTUHD has no control over that and has to disable it and relies on the client code that allows for 2K/4K formats.

## iOS version

The history has shaped YTUHD to spoof the device as iOS 14 (or higher) for those running lower. The user agent gets changed for this for YouTube server to respond with VP9 formats and all.

## Sideloading

It's been reported that the sideloaded version of YouTube will not get 2K/4K even with YTUHD included. This is because of a big reason: VP9.
Normally when an app is sideloaded, the private entitlements get removed (`com.apple.coremedia.allow-alternate-video-decoder-selection`, too) and the app won't be allowed to access hardware VP9 decoder. No known solution for bypassing this, unless you use [TrollStore](https://github.com/opa334/TrollStore) which allows for practically any entitlements, including the aforementioned, to be in your sideloaded app.
