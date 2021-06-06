//
//  ViewController.m
//  FPSDemo
//
//  Created by Tian on 2021/6/6.
//

#import "ViewController.h"
#import "SSMonitorManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[SSMonitorManager sharedManager] starMonitor];
}

@end
