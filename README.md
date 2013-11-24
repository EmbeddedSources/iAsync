# What is iAsync ?
iAsync is ***a set of IOS libraries*** that aims to make asychronous programming easy for for **Objective-C** developers. 
It uses **functional programming** ideas to solve **Callback Hell** problem. 



## Callback Hell Problem
You are suffering from the callback hell if you have a lot of nested asynchronous calls in your project. For example :
![Callback Hell](https://github.com/EmbeddedSources/iAsync/raw/readme/readme/1-Callback-Hell.png)

This makes your code hard error prone. It is hard to debug and maintain such codebase. 
There is a nice [blogpost](http://tirania.org/blog/archive/2013/Aug-15.html) and a [webinar](http://blog.xamarin.com/csharp-async-on-ios-and-android/) by @migueldeicaza .



"lib" folder:
JFFLibrary - library which include and build all projects from lib directory.

JFFAsyncOperations - used for managing of asynchronous operations
JFFNetwork - contains "asynchronous interface" functions for working with network
JFFScheduler - some useful API for creation scheduled jobs
JFFUI - contains UI components and extensions
JFFUtils - collection of useful NS classes extensions and some light classes

"app" folder:
JFFExamples - contains usage examples of JFFLibrary components.

License : BSD

Supports iOS versions 4.0 and higher. Builds using IOS SDK ver. 5.0