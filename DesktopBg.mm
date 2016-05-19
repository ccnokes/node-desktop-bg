#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <node.h>
#include <string>

using namespace v8;

//this is a C style free function
bool isMainScreen(NSScreen *screen) {
  NSScreen *main = [NSScreen mainScreen];
  return main == screen;
}

void getDesktopImages(const FunctionCallbackInfo<Value>& args) {
  Isolate *isolate = args.GetIsolate();
  Local<Array> urlsArr = Array::New(isolate);

  NSArray* screens = [NSScreen screens];

  for(NSUInteger i = 0; i < [screens count]; i++) {
    NSURL *url = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:screens[i]];
    const char *cStr = [url.path UTF8String];

    bool isMain = isMainScreen(screens[i]);

    NSDictionary *screenDescription = [screens[i] deviceDescription];
    NSNumber *displayID = [screenDescription objectForKey:@"NSScreenNumber"];
    int screenId = [displayID intValue];

    // build up object
    Local<Object> result = Object::New(isolate);
    result->Set(String::NewFromUtf8(isolate, "filepath"), String::NewFromUtf8(isolate, cStr));
    result->Set(String::NewFromUtf8(isolate, "isMain"), v8::Boolean::New(isolate, isMain));
    result->Set(String::NewFromUtf8(isolate, "id"), Number::New(isolate, screenId));

    // set object in array
    urlsArr->Set(i, result);
  }

  args.GetReturnValue().Set(urlsArr);
}

/**
 * @param {int|string} screenId|"main"
 * @param {string} file URL to new image
 * @returns {bool} worked?
 */
void setDesktopImage(const FunctionCallbackInfo<Value>& args) {
  Isolate* isolate = args.GetIsolate();
  std::string str;

  //
  if ((!args[0]->IsInt32() || !args[0]->IsString()) && !args[1]->IsString()) {
    isolate->ThrowException(String::NewFromUtf8(isolate, "Invalid arguments."));
    return;
  }
  // check if "main" string was passed
  if(args[0]->IsString()) {
    v8::String::Utf8Value s(args[0]);
    str = *s;
  }

  int screenId = args[0]->Int32Value();

  String::Utf8Value s(args[1]);
  std::string path(*s);

  // to check if it's a valid file URL according to ObjC we have to go from:
  // c++ std::string -> c string -> NSString -> NSURL
  NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:path.c_str()]];
  if([url isFileURL] == 0) {
    isolate->ThrowException(String::NewFromUtf8(isolate, "Invalid file URL. Must start with file://"));
    return;
  }

  Local<v8::Boolean> retvalue = v8::Boolean::New(isolate, false);

  NSArray *screens = [NSScreen screens];

  for(NSUInteger i = 0; i < [screens count]; i++) {
    NSDictionary *screenDescription = [screens[i] deviceDescription];
    NSNumber *displayID = [screenDescription objectForKey:@"NSScreenNumber"];
    int _id = [displayID intValue];
    if(_id == screenId || (str == "main" && isMainScreen(screens[i]))) {
      NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:nil, NSWorkspaceDesktopImageFillColorKey, [NSNumber numberWithBool:NO], NSWorkspaceDesktopImageAllowClippingKey, [NSNumber numberWithInteger:NSImageScaleProportionallyUpOrDown], NSWorkspaceDesktopImageScalingKey, nil];
      NSError *error;
      bool worked = [[NSWorkspace sharedWorkspace] setDesktopImageURL:url
                            forScreen:screens[i]
                            options:options
                            error:&error];

      retvalue = v8::Boolean::New(isolate, worked);
      break;
    }
  }
  args.GetReturnValue().Set(retvalue);
}

void Init(Local<Object> exports, Local<Object> module) {
  NODE_SET_METHOD(exports, "getDesktopImages", getDesktopImages);
  NODE_SET_METHOD(exports, "setDesktopImage", setDesktopImage);
}

NODE_MODULE(addon, Init)
