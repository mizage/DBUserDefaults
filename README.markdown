DBUserDefaults Readme
=====================


About DBUserDefaults
--------------------

DBUserDefaults is an NSUserDefaults inspired preferences system that synchronizes preferences between Macs by using [Dropbox](https://www.dropbox.com/). All the plist files are placed in "Dropbox Path"/Preferences. In addition, DBUserDefaults will monitor the directory for changes to the plist file. If a change is detected, the preferences will be reloaded and a notification will be posted so you can update your application accordingly.

DBUserDefaults does not currently offer any kind of conflict resolution. [Dropbox](https://www.dropbox.com/) itself simply makes two copies of a file and appends one with some information about the conflict. At some point in the future, conflict resolution and preference merging may be added, but for now, DBUserDefaults simply uses whichever file ["wins"](https://www.dropbox.com/help/36).

If a preferences file already exists on [Dropbox](https://www.dropbox.com/), DBUserDefaults will prompt the user and ask them if they'd like to pull the configuration from [Dropbox](https://www.dropbox.com/) or overwrite it with their local configuration.

Considerations
--------------

DBUserDefaults is thread safe. DBUserDefaults also does not collide with NSUserDefaults. If there are settings you would prefer to keep locally only, you can simply use NSUserDefaults. In addition, if a user disables [Dropbox](https://www.dropbox.com/) syncing, their preferences will be saved to ~/Library/DBPreferences

DBUserDefaults maintains a list of bundle IDs and their associated sync status in ~/.DBUserDefaults/SyncStatus.db


Example Usage
-------------

    - (void)enableDropboxButtonClicked:(NSButton*)sender
    {
      // This line enables Dropbox syncing of preferences
      [[DBUserDefaults standardUserDefaults] setDropboxSyncEnabled:YES];
    }

    // Now that syncing is enabled, we can stuff some stuff in there
    ...
    // Obtain a reference to the defaults object
    DBUserDefaults* defaults = [DBUserDefaults standardUserDefaults];
    
    [defaults setInteger:42 forKey:@"TheAnswer"];
    [defaults setObject:@"The Orchid" forKey:@"Station"];
    [defaults setBool:YES forKey:@"WouldLikeCake"];
    
    // Call this to synchronize your changes and write them out to Dropbox
    // Any other applications on other systems that also have syncing enabled
    //  will be updated
    [defaults synchronize];
    ...
    
    ...
    // Add an observer for the DBUserDefaultsDidSyncNotification to update
    //  your application to reflect the newly synchronized preferences from
    //  Dropbox.
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:DBUserDefaultsDidSyncNotification 
     object:nil 
     queue:nil 
     usingBlock:^(NSNotification *notification) 
    {
      // Obtain a reference to the defaults object
      DBUserDefaults* defaults = [DBUserDefaults standardUserDefaults];
    
      [theAnswer setStringValue:[[defaults integerForKey:@"TheAnswer"] stringValue];
      [station setStringValue:[defaults stringForKey:@"Station];
      [cakeCheckbox setIntValue:[defaults integerForKey:@"WouldLikeCake"];
    }];
    ...

Contributing
------------

If there is something you don't like about DBUserDefaults or something you would like to add, please do contact us! Feel free to fork and send pull requests. We are always open to suggestions, critiques, requests, etc. :-)


LICENSE
-------

License Agreement for Source Code provided by Mizage LLC

This software is supplied to you by Mizage LLC in consideration of your
agreement to the following terms, and your use, installation, modification or
redistribution of this software constitutes acceptance of these terms. If you do
not agree with these terms, please do not use, install, modify or redistribute
this software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Mizage LLC grants you a personal, non-exclusive license, to use,
reproduce, modify and redistribute the software, with or without modifications,
in source and/or binary forms; provided that if you redistribute the software in
its entirety and without modifications, you must retain this notice and the
following text and disclaimers in all such redistributions of the software, and
that in all cases attribution of Mizage LLC as the original author of the source
code shall be included in all such resulting software products or distributions.
Neither the name, trademarks, service marks or logos of Mizage LLC may be used
to endorse or promote products derived from the software without specific prior
written permission from Mizage LLC. Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Mizage LLC
herein, including but not limited to any patent rights that may be infringed by
your derivative works or by other works in which the software may be
incorporated.

The software is provided by Mizage LLC on an "AS IS" basis. MIZAGE LLC MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN COMBINATION
WITH YOUR PRODUCTS.

IN NO EVENT SHALL MIZAGE LLC BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
MIZAGE LLC HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
