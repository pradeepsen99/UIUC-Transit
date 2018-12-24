# Navigation for CUMTD 

An app, based on your current location in the Champaign-Urbana area, gives the nearest CUMTD bus stop and the busses that run witin those stops.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

All you need is a Mac running the latest version of XCode and Simulator installed.
* XCode Version - [10.1]
* Mac Version - [10.14.2] 

### Installing Locally

First you will need to clone the repository to your desired location

```
git clone https://github.com/pradeepsen99/mtd-bus-app-iOS.git
open ./mtd-bus-app-iOS.xcworkspace
```
And after that click the run button and set the build to either the Simulator or your very own iPhone!

## Built With

* [Swift](https://developer.apple.com/swift/) - Language
* [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) - Beta Testing
* [Icons8](https://icons8.com/ios) - In-App Icons

## Resources Used:
* [Create UITableView programmatically in Swift - Stack Overflow](https://stackoverflow.com/questions/40220905/create-uitableview-programmatically-in-swift)
* [Core Data with Swift 4 for Beginners - Shashikant Jagtap](https://medium.com/xcblog/core-data-with-swift-4-for-beginners-1fc067cca707)
* [Developer Resources CUMTD](https://developer.cumtd.com)
* [UITableView tap to deselect cell - Stack Overflow](https://stackoverflow.com/questions/29089652/selecting-and-deselecting-uitableviewcells-swift)
* [how to save and read array of array in NSUserdefaults in swift? - Stack Overflow](https://stackoverflow.com/questions/25179668/how-to-save-and-read-array-of-array-in-nsuserdefaults-in-swift)
* [How to reload tableview from another view controller in swift - Stack Overflow](https://stackoverflow.com/questions/25921623/how-to-reload-tableview-from-another-view-controller-in-swift)
* [Swift Expandable Search Bar in Header? - Stack Overflow](https://stackoverflow.com/questions/38580175/swift-expandable-search-bar-in-header)
* [Search controller below navigation item prior to iOS 11 - Stack Overflow](https://stackoverflow.com/questions/46515105/search-controller-below-navigation-item-prior-to-ios-11)
* [iOS 11 customise search bar in navigation bar - Stack Overflow](https://stackoverflow.com/questions/46007260/ios-11-customise-search-bar-in-navigation-bar)
* [Local Notifications with iOS 10 - useyourloaf](https://useyourloaf.com/blog/local-notifications-with-ios-10/)

## TODO

* - [x] Display route info on clicking on a stop.
* - [x] Favorites Tab with Favorite bus stops.
* - [x] Search bar for any stop in 'stops' tab.
* - [x] Add dynamic favorites button.
* - [x] Settings tab with settings related to app.
* - [x] Add slide down to refresh option.
* - [x] Fix bug where StopsViewController doesn't reset searches after clicking away.
* - [ ] Revamp the way notifications work. Add an adjustable option for how many mins warning needed.
* - [ ] Add API limits such as refreshing routes only once a mintue and changelog stuff.
* - [ ] Info on the route when clicked such as current location and distance to stop.
* - [ ] Info on the Bus stop when clicked such as lat+long and show in Maps/Google Maps.
* - [x] Notifications on scheduled bus arrivial.
* - [x] 3D-Touch compatability inside app.
* - [ ] 3D-Touch compatability outside app to acess tabs inside the app.
* - [ ] Watch App compatability.
* - [ ] Notifications on watch app.
* - [ ] Splash Screen.
* - [ ] App Icons.
* - [ ] Night Mode.
* - [ ] Color blind Mode.

## Authors

* **Pradeep Senthil** [pradeepsen99](https://github.com/pradeepsen99)

## License

```
BSD 3-Clause License

Copyright (c) 2018, Pradeep Senthil
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```