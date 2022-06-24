

#import "CCbVideoData.h"

@implementation CCbVideoData

@synthesize pData;
@synthesize nLen;
@synthesize nType;
@synthesize uTimeStamp;
@synthesize utcTimeStamp;
- (id) init {
    self = [super init];
    if (self) {
        pData = NULL;
        nLen = 0;
        nType = 0;
        uTimeStamp = 0;
        utcTimeStamp = 0;
    }
    return self;
}

- (void) dealloc {
    if(pData != NULL)
    {
        free(pData);
    }
}

@end
