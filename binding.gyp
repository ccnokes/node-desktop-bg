{
 "targets": [
   {
     "target_name": "DesktopBg",
     "sources": [ "DesktopBg.mm" ],
      "xcode_settings": {
        "OTHER_CPLUSPLUSFLAGS": ["-std=c++11", "-stdlib=libc++", "-mmacosx-version-min=10.8"],
        "OTHER_LDFLAGS": ["-framework CoreFoundation -framework IOKit -framework AppKit"]
      }
   }
 ]
}
