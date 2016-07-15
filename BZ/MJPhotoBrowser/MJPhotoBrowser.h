
#import <UIKit/UIKit.h>

@protocol MJPhotoBrowserDelegate;

@interface MJPhotoBrowser : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id<MJPhotoBrowserDelegate> delegate;

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, assign) NSUInteger currentPhotoIndex;

- (void)show;
@end

@protocol MJPhotoBrowserDelegate <NSObject>
@optional

- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

- (void)photoBrowserHide:(NSUInteger)index;

@end
