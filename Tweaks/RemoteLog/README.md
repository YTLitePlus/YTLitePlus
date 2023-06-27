## Usage

RemoteLog supports all the format specifiers of `NSLog` so it should be very easy to migrate to.

- Copy `RemoteLog.h` to `$THEOS/include`
- Change the ip addresses in the `RemoteLog.h` file to match your computer's ip address
- Include the header in any source files you want to use it in:
```
#include <RemoteLog.h>
```
- Replace calls to `NSLog` with calls to `RLog`:
```
RLog(@"Test log: %@", someObject);
```
- Run the python server on your computer and watch the logs coming in :)
