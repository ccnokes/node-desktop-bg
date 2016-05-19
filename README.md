# node-desktop-bg

This is my first attempt at a native node module. It only works on Mac OSX currently. Maybe I'll try to get Windows and Linux working on it someday. 

## API

### `getDesktopImages`
This returns:
```javascript
[
  {
    filepath: '/Library/Desktop Pictures/Earth and Moon.jpg', //absolute path to file
    isMain: true, // is it the main screen or a secondary?
    id: 2077750397 // the screeen id. note that this changes if the user connects/disconnects a display
  }
]
```

### `setDesktopImages`
Params:
```
{int|string} screen id|"main"
{string} File URL to new image. Must start with "file://"
```
Returns `true` if it worked. The existence of the file URL is not checked.


## Sample

```javascript
const DesktopBg = require('node-desktop-bg');

console.log(DesktopBg.getDesktopImages());

DesktopBg.getDesktopImages().forEach(screen => {
  DesktopBg.setDesktopImage(screen.id, 'file:///Images/RickAstley/Rickrolling.png');
});
```
