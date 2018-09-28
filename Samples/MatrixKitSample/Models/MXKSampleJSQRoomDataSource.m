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

#import "MXKSampleJSQRoomDataSource.h"
#import "MXKSampleJSQRoomBubbleCellData.h"


@implementation MXKSampleJSQRoomDataSource

- (instancetype)initWithRoomId:(NSString *)roomId andMatrixSession:(MXSession *)session
{
    self = [super initWithRoomId:roomId andMatrixSession:session];
    if (self)
    {
        // Change data classes
        [self registerCellDataClass:MXKSampleJSQRoomBubbleCellData.class forCellIdentifier:kMXKRoomBubbleCellDataIdentifier];
    }
    return self;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessageData> messageData;
    @synchronized(bubbles)
    {
        // TODO: Fix it
        //messageData = bubbles[indexPath.item];
    }
    return messageData;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count;
    @synchronized(bubbles)
    {
        count = bubbles.count;
    }
    return count;
}

@end
