
#import <Foundation/Foundation.h>

@interface CCbVideoData : NSObject
{
    @public
    char pData_ext[4096];
}

@property (nonatomic,assign)int nLen;
@property (nonatomic,assign)int nType;
@property (nonatomic,assign)unsigned int uTimeStamp;
@property (nonatomic)char* pData;
@property (nonatomic,assign)unsigned long long utcTimeStamp;

@property (nonatomic,strong)NSData *bufferData;

@end
