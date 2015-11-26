/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKRoomDetailsViewController.h"

#import "NSBundle+MatrixKit.h"

@interface MXKRoomDetailsViewController()
{    
    // nav barbutton
    UIBarButtonItem* doneButton;
    
    // the room events listener
    id roomListener;
}
@end

@implementation MXKRoomDetailsViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([MXKRoomDetailsViewController class])
                          bundle:[NSBundle bundleForClass:[MXKRoomDetailsViewController class]]];
}

+ (instancetype)roomDetailsViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([MXKRoomDetailsViewController class])
                                          bundle:[NSBundle bundleForClass:[MXKRoomDetailsViewController class]]];
}

#pragma mark - Public API

/**
 Set the dedicated session and the room Id
 */
- (void) initWithSession:(MXSession*)aSession andRoomId:(NSString*)aRoomId
{
    _session = aSession;
    _roomId = aRoomId;
    
    // sanity checks
    if (aSession && aRoomId)
    {
        mxRoom = [aSession roomWithRoomId:aRoomId];
    }
    
    if (mxRoom)
    {
        // Register a listener to handle messages related to room name, topic...
        roomListener = [mxRoom listenToEventsOfTypes:@[kMXEventTypeStringRoomName, kMXEventTypeStringRoomAliases, kMXEventTypeStringRoomMember]
                                             onEvent:^(MXEvent *event, MXEventDirection direction, MXRoomState *roomState)
                        {
                            // Consider only live events
                            if (direction == MXEventDirectionForwards)
                            {
                                if (event.eventType != MXEventTypeRoomMember || !self.isEditing)
                                {
                                    [self refreshDisplay:mxRoom.state];
                                }
                            }
                        }];
        
        mxRoomState = mxRoom.state;
        [self checkIfSuperUser];
    }
    
    self.title = [NSBundle mxk_localizedStringForKey:@"room_details_title"];
    
    doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - private methods

- (void)checkIfSuperUser
{
    // Check whether the user has enough power to rename the room
    MXRoomPowerLevels *powerLevels = [mxRoomState powerLevels];
    NSUInteger userPowerLevel = [powerLevels powerLevelOfUserWithUserID:_session.myUser.userId];
    
    isSuperUser = (userPowerLevel >= [powerLevels minimumPowerLevelForSendingEventAsStateEvent:kMXEventTypeStringRoomName]);
}

- (void)refreshDisplay:(MXRoomState*)newRoomState
{
    // the inherited classes could partially disable the refresh
    // e.g. if the user set a new value, the refresh could be locked
    mxRoomState = newRoomState.copy;
    
    [self checkIfSuperUser];
    [self.tableView reloadData];
}

- (void)destroy
{
    if (roomListener)
    {
        [mxRoom removeListener:roomListener];
        roomListener = nil;
    }
}

#pragma mark - Action

- (IBAction) onDone:(id)sender
{
    // should check if there are some updates before closing
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

// empty by default

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end