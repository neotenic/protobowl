#ProtoBowl

Okay, so I think NPM would complain if I didn't have a readme, so I guess I'll start writing something which might be mistaken for a readme given a certain number of prior conditions.

#Manual

Okay, so this application probably ranks among one of the largest things I've ever done, which actually does say something as to its scope. However, it's still designed to be fast and responsive and what not.

But it's got a somewhat large scope which makes me believe that it may be useful to have a sort of overview not of how things work (that's what the code is for), but a somewhat deeper look into what it does. What kinds of features and little tricks.

## Responsive Design

Yeah, yeah, buzzwords galore. It's responsively designed which means that it should, at least in theory, work on all screen sizes, from gigantic monitor walls of 60 HD displays (I've only tested the application on six WXQGA monitors) to an iPhone screen (I won't venture any smaller, because running on watches represents a significant effort beyond what I already have).

It's been tested on a few browsers, Chrome (on Linux, Windows, iPad, Galaxy Nexus) and Firefox and Safari on iPad. 

It's built with Twitter Bootstrap, sans fugly black bar on top, so it should inherit most of the responsiveness. Also, it uses Font Awesome for all glyphs and that means everything's vector and smoth even at absurd pixel densities.

## Offline

Protobowl was designed first with a flexible sync architecture. However, regrettably, it wasn't designed with the idea of Offline-first. Don't get me wrong, offline works great, but it's implemented with a offline.coffee which is largely (I'd say 80%) a reimplementation of methods in web.coffee. That's not a good quantity of don't repeat yourself, or at least it's hardly ideal.

However, by virtue of running off Node, there's a single language (javascript) which runs both client and server. As such there's a natural ability to reuse some code, in this case, all the supporting libraries are shared between client and server, the answer checking (which is surprisingly sophisticated, albeit likely unnecessarily so). 

Offline was built with Appcache in mind, that's pretty obvious because you sort of need appcache to make things work offline. The offline code is loaded asynchronously and there isn't any fundamental difference between offline-start and disconnect behavior. So that means there isn't any fumbling between multiple copies of the code or any limitation on the functionality of the offline mode. You can disconnect from the server in the midst of the game, perhaps because of a flaky connection and you can continue without interruption. And it even tries to automatically reconnect, and picks up the state and resumes (albeit, probably losing what you've done offline).

## Interface

This is what I really think matters, how to actually use it, and the little interaction features.

### Keyboard

The primary interface is meant to be the keyboard. In fact, early design sketches didn't even include a button bar for the desktop UI. Eventually, I relented, and there's now buttons, but still, use keyboards.

The first button is `space`, which make sense because it's the biggest button and also probably the most important. Space generally means "buzz", however there's another very small thing it does: when you open up and see that big green button saying "start the game", you can also press space to trigger that (no ambiguity since the buzz button is disabled in such circumstances).

Next, or skipping, as it was referred to in earlier iterations is also a fairly commonplace operation. It can be accessed with not one, but three keys, `S`, `N` and `J`. `S` and `N` are probably pretty obvious, referring to "Skip" and "Next". J is just convienient because it's on the home row (well, so is `S`, technically) and usually refers to "down" for people who use Vi (which notably doesn't include me, but Gmail, Google Reader and Google Wave, three applications that I did, at some point in time use also follow that pattern). 

Pause and Resume can be accessed with `P` and `R`, and are both equivalent. So you can technically pause with `R`, and resume with `P`, though that would be metaphorically confusing. 

Since it's designed to be "social", if you don't mind me tossing around more loaded buzzwords, chat was one of the first features added (also one of the easiest, but that doesn't help me rewrite history). Chat is accessed through the `/` key, that is, the forward slash. For those who don't like letters which aren't in the alphabet, it's also accessible through the letter `C`.

### Buttons

Yeah, buttons, they exist. But they're only meant to be used on mobile.

### Other things you can click on

There are a number of non-button things which can be clicked on as well.


#### Breadcrumbs

The "breadcrumb", as Bootstrap calls it, is the little row which precedes every question which includes the category, difficulty and tournament to which the question belongs. The one on the top isn't clickable, but all the other ones are. Clicking on those expands the question readout which gets collapsed below them.

Within the breadcrumb is a slightly grayed out word "Report", which can be clicked on to bring up a (as of yet non functional) modal dialog to submit a question for manual review in case there was something wrong with the question. For instance, maybe the question was formatted wrong or truncated, or you're exceedingly pedantic and think that there is a typo which hinders your ability to participate, or something. 

Also, on the far right is a blue star which can be clicked on to "bookmark" a question. Right now, bookmarking does little other than filling in that blue star and preventing the question from getting deleted (questions that drop far enough down get deleted unless they're bookmarked). However, in the future, it may be imaginable that the bookmarked questions would be added to some kind of interface which could be managed by the server.

The breadcrumb also reveals the answer to the question whenever the question is over.

#### Leaderboard/Statistics

In multiplayer mode, there is a leaderboard showing a ranking of all the users who have particpated in the room. In single player, it's just a single grid giving your statistics.

##### Multiplayer

It's a grid, which is pretty cool, the first row is the ranking and the score, the latter of which is inside a bubble which is colored. The score is at the moment computed based on the number of "early" answers, which are correct answers before the asterisk in applicable packets, the number of interrupts and the number of correct answers. The current weights are 15 for an early answer, 10 for a correct answer and -5 for an interrupt. The colors of the bubble denote the online status of the player:

* `gray` the user is offline and has no connected sessions at that moment
* `orange` the user has not interacted with the game in the past 10 minutes, but has at least one session open
* `green` the user is online and has interacted with the room in the past 10 minutes
* `blue` this row corresponds to you

On the adjacent column is the user's name and there is another column for the number of interrupts. There aren't any more because there isn't much space.

Clicking on any of the rows brings up a popover which gives a more complete breakdown of the user and his or her performance. That dialog can be dismissed by clicking (or tapping, for touch devices) again on the same row.

##### Single Player/Offline

The single player mode has aesthetic similarities to the detailed popover of the multiplayer mode and this is hardly a coincidence. The default view for single player mode is just an abridged version of the popover's view including only the score, the number correct, the number of interrupts and the total number of guesses. Clicking on the single player interface anywhere will reveal the more detailed interface (with purty sliding effects courtesy of jQuery).

On the single player header the "offline" badge lights up, well, quite obviously, when the user is offline.

It also has shiny transitions between single player and multiplayer modes.

## Debugging

The debugging panel is the furthest down and takes the form of what looks like a table. The first two rows sound vaguely technical (with an underscore too!), latency and sync_offset. And you'd be right, they're both just little metrics which go indicate the health of the network connection. 

The titling of "Debugging" is a tad disingenous, it's mostly networking. But then again, networking is like the vast majority of what can actually fail. 

The very last in the menu is a link that quite plainly says "Disconnect", and opposite is a piece of text representing the application cache's status. Disconnect is nice for when the network's flakey and you know your connection won't last long anyway. Or if you're like antisocial and need to make your own little corner to cry in. Or something like that. Sure. Okay. Next.

### The Main Interface

I think I'm going to start over with this manual.