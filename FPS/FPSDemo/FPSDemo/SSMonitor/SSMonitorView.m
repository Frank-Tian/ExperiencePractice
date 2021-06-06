//
//  SSMonitorView.m
//  StarStar
//
//  Created by tian on 2019/5/20.
//  Copyright © 2019 tian. All rights reserved.
//

#import "SSMonitorView.h"

static NSInteger kMonitorItemCount = 11;
static NSInteger kMonitorLabelBaseTag = 1150;

@implementation SSMonitorInfoModel


@end

@interface SSMonitorView ()

@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation SSMonitorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.labels = [NSMutableArray array];
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    [self addGestureRecognizer:panGR];
    
    for (int i = 0; i < kMonitorItemCount; i++) {
        UILabel *label = [self creatLabel];
        label.tag = kMonitorLabelBaseTag + i;
        [self addSubview:label];
        [self.labels addObject:label];
    }
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self addSubview:self.closeBtn];
    [self addSubview:self.toggleBtn];
    [self.toggleBtn addTarget:self action:@selector(toggleFullInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    self.clipsToBounds = YES;
}

- (UILabel *)creatLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:11];
    return label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 10;
    CGFloat width = self.frame.size.width -margin*2;
    CGFloat height = self.frame.size.height / [self showItemCount];
    
    CGFloat y = 0;
    for (int i = 0; i < self.labels.count; i++) {
        UILabel *label = [self.labels objectAtIndex:i];
        label.frame = CGRectMake(margin, y, width, height);
        y = CGRectGetMaxY(label.frame);
    }

    CGFloat closeBtnW = 40;
    self.closeBtn.frame = CGRectMake(self.frame.size.width - closeBtnW + 5, -5, closeBtnW, closeBtnW);
    self.toggleBtn.frame = CGRectMake((self.frame.size.width-40)/2.0,0,40, 20);
}

- (void)updateMonitorInfo:(SSMonitorInfoModel *)info
{
    NSInteger uid = 100;
    NSString *uname = @"Name";
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];

    UIDevice *device = [[UIDevice alloc] init];
    NSString *systemName = device.systemName;       // 获取当前运行的系统
    NSString *systemVersion = device.systemVersion; // 获取当前系统的版本
    
    UIColor *warningColor = [UIColor redColor];

    UIColor *whiteColor = [UIColor whiteColor];
    NSAttributedString *cpuAttr = [self getAttrByNormal:@"CPU使用率："
                                          highlightInfo:[NSString stringWithFormat:@"%.2f%%",info.cpu]
                                                  color:info.cpu > 80 ? warningColor : whiteColor];

    NSAttributedString *threadText = [self getAttrByNormal:@"当前线程数："
                                             highlightInfo:[NSString stringWithFormat:@"%lu",info.threadCount]
                                                     color:info.threadCount > 50 ? warningColor : whiteColor];

    NSAttributedString *usedMemonryText = [self getAttrByNormal:@"App占用内存："
                                                  highlightInfo:[NSString stringWithFormat:@"%.2f M",info.memoryUsed]
                                                          color:info.memoryUsed > 300 ? warningColor : whiteColor];
    NSAttributedString *totalMemoryText = [self getAttrByNormal:@"机身内存："
                                                  highlightInfo:[NSString stringWithFormat:@"%.2f M",info.totalMemory]
                                                          color:info.totalMemory > 1024 ? [UIColor greenColor] : whiteColor];
    NSString *availableMemoryText = [NSString stringWithFormat:@"当前可用内存：%.2f M",info.availableMemory];
    NSInteger fps = info.fps;
    UIColor *fpsColor = warningColor;
    if (fps > 55) {
        fpsColor = [UIColor greenColor];
    } else if (fps >40) {
        fpsColor = [UIColor orangeColor];
    }
    NSAttributedString *fpsText = [self getAttrByNormal:@"FPS："
                                          highlightInfo:[NSString stringWithFormat:@"%ld (%ld)",fps ,info.avgFps]
                                                  color:fpsColor];
    NSString *userIDText = [NSString stringWithFormat:@"UID：%ld",uid];
    NSString *userNameText = [NSString stringWithFormat:@"用户昵称：%@",uname];
    NSString *versionText = [NSString stringWithFormat:@"程序版本：%@(%@)",appVersion,appBuildVersion];
    NSString *systemVersionText = [NSString stringWithFormat:@"操作系统：%@(%@)",systemName,systemVersion];
    NSArray *titles = @[
                        @"",
                        fpsText,
                        cpuAttr,
                        threadText,
                        usedMemonryText,
                        availableMemoryText,
                        totalMemoryText,
                        @"",
                        userIDText,
                        userNameText,
                        versionText,
                        systemVersionText,
                        ];
    for (int i = 0; i < self.labels.count; i++) {
        UILabel *label = [self.labels objectAtIndex:i];
        NSString *title = [titles objectAtIndex:i];
        if ([title isKindOfClass:[NSAttributedString class]]) {
            label.attributedText = (NSAttributedString *)title;
        } else {
            label.text = title;
        }
    }
}

- (NSAttributedString *)getAttrByNormal:(NSString *)normal highlightInfo:(NSString *)highlight color:(UIColor *)color
{
    NSMutableAttributedString *info = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",normal,highlight]];
    NSDictionary *dict = @{NSForegroundColorAttributeName : color};
    [info addAttributes:dict range:NSMakeRange(normal.length, highlight.length)];
    return info;
}

- (void)toggleFullInfo:(UIButton *)btn
{
    btn.selected = !btn.selected;
    CGRect frame = self.frame;
    frame.size.height = [self showFullInfo] ? frame.size.height * 2 : frame.size.height / 2;
    self.frame = frame;
}

- (BOOL)showFullInfo
{
    return self.toggleBtn.selected;
}

- (NSInteger)showItemCount
{
    return [self showFullInfo] ? kMonitorItemCount : ceilf(kMonitorItemCount / 2.0);
}

#pragma mark - Getter

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setTitle:@"关" forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UIButton *)toggleBtn
{
    if (!_toggleBtn) {
        _toggleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toggleBtn setTitle:@"精简" forState:UIControlStateSelected];
        [_toggleBtn setTitle:@"全量" forState:UIControlStateNormal];
        _toggleBtn.backgroundColor = [UIColor blackColor];
        _toggleBtn.titleLabel.textColor = [UIColor whiteColor];
        _toggleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _toggleBtn;
}

#pragma mark - Move

- (void)panHandle:(UIPanGestureRecognizer *)panGR
{
    CGPoint transition = [panGR translationInView:self];
    [panGR setTranslation:CGPointZero inView:self];
    
    switch (panGR.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat x = self.frame.origin.x + transition.x;
            CGFloat y = self.frame.origin.y + transition.y;
            CGFloat maxX = self.superview.bounds.size.width - self.frame.size.width;
            CGFloat maxY = self.superview.bounds.size.height - self.frame.size.height;
            if (x < 0) x = 0;
            if (x > maxX) x = maxX;
            if (y < 0) y = 0;
            if (y > maxY) y = maxY;
            self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!self.userInteractionEnabled) return;
            CGFloat margin = 2;
            BOOL isDelete = NO;
            if (isDelete) return;
            BOOL isToLeft = CGRectGetMidX(self.frame) < self.superview.bounds.size.width * 0.5;
            CGFloat x;
            CGFloat y = self.frame.origin.y;
            CGFloat w = self.frame.size.width;
            CGFloat h = self.frame.size.height;
            if (isToLeft) {
                x = margin;
            } else {
                x = self.superview.bounds.size.width - margin  - w;
            }
            if (y < margin) {
                y = margin;
            }
            if (CGRectGetMaxY(self.frame) > (self.superview.bounds.size.height - margin)) {
                y = self.superview.bounds.size.height - margin - h;
            }
            CGRect suspensionFrame = CGRectMake(x, y, w, h);
            [self updateSuspensionFrame:suspensionFrame animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)updateSuspensionFrame:(CGRect)suspensionFrame animated:(BOOL)animated
{
    if (animated) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.55
                              delay:0
             usingSpringWithDamping:0.78
              initialSpringVelocity:0.1
                            options:kNilOptions animations:^{
                                self.frame = suspensionFrame;
                            } completion:^(BOOL finished) {
                                self.userInteractionEnabled = YES;
                            }];
    } else {
        self.frame = suspensionFrame;
        self.userInteractionEnabled = YES;
    }
}

@end
