# Project 1 - *Movie Viewer*

**Movie Viewer** is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **30** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies currently playing in theaters. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees an error message when there is a network error.
- [x] User can pull to refresh the movie list.

The following **optional** features are implemented:

- [x] Add a tab bar for **Now Playing** and **Top Rated** movies.
- [x] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in.
- [x] For the large poster, load the low-res image first, switch to high-res when complete.
- [x] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

- [x] UI Animations
- [x] Display Movie Cast Pictures on Details View 

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](movieViewer-take1.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes
- This code had been developed only for iPhone 6/6s running in portrait mode
- Displaying network error in the start of the video because I wanted to have only 1 demo video instead of a bunch of videos
- I was stuck for the longest time switching between table view and collection view. 'weak' reference got the best of me
- I also wanted to add a button to view the movie trailer but I did not find a pod compatible with xcode 8 


## License

    Copyright 2016 Saurabh Patwardhan

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
