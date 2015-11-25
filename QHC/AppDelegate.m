//
//  AppDelegate.m
//  QHC
//
//  Created by qhc2015 on 15/6/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "AppDelegate.h"
#import "CZNewFeatureController.h"
#import "QHCHomeViewController.h"
#import "QHCBespeakViewController.h"
#import "QHCMeViewController.h"
#import "QHCMoreViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "SDImageCache.h"


@interface AppDelegate ()
-(void)initMainView;
@end

@implementation AppDelegate

@synthesize myRootController;
@synthesize tabBarController;
@synthesize mapView;
@synthesize locationAddrMutDic;
@synthesize search;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //高德地图  配置用户Key
    [MAMapServices sharedServices].apiKey = @"d4520fa0bc1b417d8ca9ca50e376fa66";
    self.mapView = [[MAMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    
    //向微信注册
    [WXApi registerApp:@"wx630d0f78b6802679"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //    添加默认城市
    [userDefaults setObject:@"广州市" forKey:DEFAULT_CITY];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //初始化根视图控制器
    self.myRootController = [[UINavigationController alloc] init];
    myRootController.navigationBarHidden = YES;
    //初始化主页
    [self initMainView];
    
    //获取是否是第一次使用的标记
    NSString *notFirstUse = [userDefaults stringForKey:@"notFirstUse"];
    if ([notFirstUse isEqualToString:@"true"]) {//如果不是第一次使用，则进入主页
        self.window.rootViewController = myRootController;
    } else {//否则进入NewFeature（宣传画）界面
        CZNewFeatureController *vc = [[CZNewFeatureController alloc]initWithType:0];
        self.window.rootViewController = vc;
    }
//    [NSThread sleepForTimeInterval:2.0];//让launch停留一段时间
    [self.window makeKeyAndVisible];
    
    return YES;
}

////微信功能需要重写此方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}
//微信支付功能需要重写此方法 支付宝支付也会回调这个方法，当手机有支付宝客户端的时候
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic) {
             NSLog(@"111result = %@", resultDic);
         }];
        return YES;
    } else {
        NSLog(@"WX  url = %@", url);
        return [WXApi handleOpenURL:url delegate:self];
    }
}
//
////onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
-(void) onReq:(BaseReq*)req {
    
}
//
////如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
-(void) onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        if (self.delegate) {
            [self.delegate WXPayResult:response.errCode];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//初始化主页视图
-(void)initMainView {
    
    //创建“首页”视图控制器
    QHCHomeViewController *homeViewCtr = [[QHCHomeViewController alloc] init];
    //创建“预约”视图控制器
    QHCBespeakViewController *bespeakViewCtr = [[QHCBespeakViewController alloc] init];
    //创建“我的”视图控制器
    QHCMeViewController *meViewCtr = [[QHCMeViewController alloc] init];
    //创建“更多”视图控制器
    QHCMoreViewController *moreViewCtr = [[QHCMoreViewController alloc] init];
    
    //创建UITabBarController控制器
    self.tabBarController = [[UITabBarController alloc]init];
    [[UITabBar appearance] setBarTintColor:[UIColor tableViewBackgroundColor]];//修改UITabBar的显示颜色
//    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabBarBg.png"]];//设置UIabBar的背景图片
    tabBarController.view.backgroundColor = [UIColor viewBackgroundColor];
    //设置委托www.2cto.com
    tabBarController.delegate = self;
    //加入一个数组
    NSArray* controllerArray = [[NSArray alloc]initWithObjects:homeViewCtr,bespeakViewCtr,meViewCtr,moreViewCtr ,nil];
    //设置UITabBarController控制器的viewControllers属性为我们之前生成的数组controllerArray
    tabBarController.viewControllers = controllerArray;
    
    //定义平常状态下的字体颜色和大小
    NSDictionary *dictNom = [NSDictionary dictionaryWithObjectsAndKeys:LABEL_DEFAULT_TEXT_COLOR,NSForegroundColorAttributeName, [UIFont systemFontOfSize:12.0], NSFontAttributeName, nil];
    //定义选中状态下的字体颜色和大小；
    NSDictionary *dictSel = [NSDictionary dictionaryWithObjectsAndKeys:LABEL_DEFAULT_TEXT_COLOR,NSForegroundColorAttributeName, [UIFont systemFontOfSize:13.0], NSFontAttributeName, nil];
    
    //设置TabBarItem的标题与图片//30 * 30
    UITabBarItem *tbItem = (UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:0];
    //定义title的颜色和大小
    [tbItem setTitleTextAttributes:dictNom forState:UIControlStateNormal];
    [tbItem setTitleTextAttributes:dictSel forState:UIControlStateSelected];
    UIImage *nomImg = [UIImage imageNamed:@"tab_home.png"];
    UIImage *selImg = [UIImage imageNamed:@"tab_home_s.png"];
    //如果不希望使用tabar的item图片的系统默认蓝色，则需要对图片加上属性：UIImageRenderingModeAlwaysOriginal
    nomImg = [nomImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selImg = [selImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tbItem = [tbItem initWithTitle:@"首页" image:nomImg selectedImage:selImg];
    
    tbItem = (UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:1];
    //定义title的颜色和大小
    [tbItem setTitleTextAttributes:dictNom forState:UIControlStateNormal];
    [tbItem setTitleTextAttributes:dictSel forState:UIControlStateSelected];
    nomImg = [UIImage imageNamed:@"tab_bespeak.png"];
    selImg = [UIImage imageNamed:@"tab_bespeak_s.png"];
    //如果不希望使用tabar的item图片的系统默认蓝色，则需要对图片加上属性：UIImageRenderingModeAlwaysOriginal
    nomImg = [nomImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selImg = [selImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tbItem = [tbItem initWithTitle:@"预约单" image:nomImg selectedImage:selImg];
    
    tbItem = (UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:2];
    //定义title的颜色和大小
    [tbItem setTitleTextAttributes:dictNom forState:UIControlStateNormal];
    [tbItem setTitleTextAttributes:dictSel forState:UIControlStateSelected];
    nomImg = [UIImage imageNamed:@"tab_me.png"];
    selImg = [UIImage imageNamed:@"tab_me_s.png"];
    //如果不希望使用tabar的item图片的系统默认蓝色，则需要对图片加上属性：UIImageRenderingModeAlwaysOriginal
    nomImg = [nomImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selImg = [selImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tbItem = [tbItem initWithTitle:@"我的" image:nomImg selectedImage:selImg];
    
    tbItem = (UITabBarItem *)[tabBarController.tabBar.items objectAtIndex:3];
    //定义title的颜色和大小
    [tbItem setTitleTextAttributes:dictNom forState:UIControlStateNormal];
    [tbItem setTitleTextAttributes:dictSel forState:UIControlStateSelected];
    nomImg = [UIImage imageNamed:@"tab_more.png"];
    selImg = [UIImage imageNamed:@"tab_more_s.png"];
    //如果不希望使用tabar的item图片的系统默认蓝色，则需要对图片加上属性：UIImageRenderingModeAlwaysOriginal
    nomImg = [nomImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selImg = [selImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tbItem = [tbItem initWithTitle:@"更多" image:nomImg selectedImage:selImg];
    
    //读取
//    UIViewController* activeController = tabBarController.selectedViewController;
    //默认选择第1个视图选项卡（索引从0开始的）
    tabBarController.selectedIndex = 0;
    
    [myRootController pushViewController:tabBarController animated:NO];
    
}

//创建页面部标题视图
+(UIView*)createTopTitleView {
    float statusHeight = 20.0;
    float tvWidth = [UIScreen mainScreen].applicationFrame.size.width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, CONTENT_OFFSET+statusHeight)];
    topView.backgroundColor = [UIColor titleBarBackgroundColor];
    //背景图片
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, CONTENT_OFFSET+statusHeight)];
    [bgImgView setImage:[UIImage imageNamed:@"titlebar_bg.png"]];
    [bgImgView setTag:TITLE_BACKGROUND];
    [topView addSubview:bgImgView];
    //左边按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, statusHeight, CONTENT_OFFSET + 6, CONTENT_OFFSET)];
    [leftButton setTag:LEFT_BUTTON];
    leftButton.hidden = YES;
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = BUTTON_TEXT_FONT;
    [topView addSubview:leftButton];
    //右边按钮
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(tvWidth - CONTENT_OFFSET*1.5 - 5.0, statusHeight, CONTENT_OFFSET*1.5, CONTENT_OFFSET)];
    [rightButton setTag:RIGHT_BUTTON];
    rightButton.hidden = YES;
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = BUTTON_TEXT_FONT;
    [topView addSubview:rightButton];
    //页面标题文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_OFFSET + 5.0, statusHeight, tvWidth - 2*CONTENT_OFFSET, CONTENT_OFFSET)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setTag:TITLE];
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    [topView addSubview:titleLabel];
    
    return topView;
}

////创建页面部标题视图
//+(UIView*)createTopTitleView {
//    float tvWidth = [UIScreen mainScreen].applicationFrame.size.width;
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, CONTENT_OFFSET)];
//    topView.backgroundColor = [UIColor titleBarBackgroundColor];
//    //背景图片
//    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, CONTENT_OFFSET)];
//    [bgImgView setImage:[UIImage imageNamed:@"topTitleBg.png"]];
//    [bgImgView setTag:TITLE_BACKGROUND];
//    [topView addSubview:bgImgView];
//    //左边按钮
//    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CONTENT_OFFSET + 6, CONTENT_OFFSET)];
//    [leftButton setTag:LEFT_BUTTON];
//    leftButton.hidden = YES;
//    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    leftButton.titleLabel.font = BUTTON_TEXT_FONT;
//    [topView addSubview:leftButton];
//    //右边按钮
//    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(tvWidth - CONTENT_OFFSET - 5.0, 0.0, CONTENT_OFFSET, CONTENT_OFFSET)];
//    [rightButton setTag:RIGHT_BUTTON];
//    rightButton.hidden = YES;
//    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    leftButton.titleLabel.font = BUTTON_TEXT_FONT;
//    [topView addSubview:rightButton];
//    //页面标题文字
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_OFFSET + 5.0, 0.0, tvWidth - 2*CONTENT_OFFSET, CONTENT_OFFSET)];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.textColor = [UIColor whiteColor];
//    [titleLabel setTag:TITLE];
//    titleLabel.font = [UIFont systemFontOfSize:18.0];
//    [topView addSubview:titleLabel];
//    
//    return topView;
//}

//创建状态栏背景
+(UIImageView*)createStatusBackground {
    //背景图片
    float tvWidth = [UIScreen mainScreen].applicationFrame.size.width;
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, tvWidth, CONTENT_OFFSET)];
    [bgImgView setImage:[UIImage imageNamed:@"topTitleBg.png"]];
    return bgImgView;
}


#pragma MAMapViewDelegate
/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation;{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        [self searchAddress];
    }
}

#pragma marks 逆向地理编码
-(void)searchAddress
{
    AppDelegate *appDelegate = (AppDelegate*)([UIApplication sharedApplication].delegate);
    CLLocationCoordinate2D centerCoordinate = appDelegate.mapView.userLocation.location.coordinate;
    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
    
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
    regeoRequest.searchType = AMapSearchType_ReGeocode;
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    regeoRequest.radius = 10000;
    regeoRequest.requireExtension = YES;
    
    //发起逆地理编码
    [search AMapReGoecodeSearch: regeoRequest];
    
}

#pragma marks AMapSearchDelegate
//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (nil == self.locationAddrMutDic) {
        self.locationAddrMutDic = [[NSMutableDictionary alloc] init];
    }
    if(response.regeocode != nil)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
        //        对于直辖市，response.regeocode.addressComponent对象的city属性值为空，province属性中是直辖市名称。
        [self.locationAddrMutDic setObject:response.regeocode.addressComponent.province forKey:@"province"];//省或直辖市
        if(response.regeocode.addressComponent.city){
            [self.locationAddrMutDic setObject:response.regeocode.addressComponent.city forKey:@"city"];//市 为直辖市时 此值为空
            //    添加定位到的城市
            [userDefaults setObject:response.regeocode.addressComponent.city forKey:LOCATION_CITY];
        } else {
            [userDefaults setObject:response.regeocode.addressComponent.province forKey:LOCATION_CITY];
        }
        [locationAddrMutDic setObject:response.regeocode.addressComponent.district forKey:@"district"];//区 镇
        [locationAddrMutDic setObject:response.regeocode.addressComponent.township forKey:@"township"];//街道
        
        NSLog(@"ReGeo: %@", result);
    }
    
    
}


#pragma marks getLabelSize
+(CGSize) getStringInLabelSize:(NSString*)string andFont:(UIFont*)font andLabelWidth:(float)width {
    //设置段落模式
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSLineBreakByWordWrapping;
    NSDictionary *attribute = @{NSFontAttributeName:font, NSParagraphStyleAttributeName: paragraph};
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return size;
}


#pragma marks SDIMageCache
+ (void)clearTmpPics
{
    [[SDImageCache sharedImageCache] clearDisk];
    
    //    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    
    NSLog(@"clear disk");
    
//    float tmpSize = [[SDImageCache sharedImageCache] checkTmpSize];
//    float tmpSize = [[SDImageCache sharedImageCache] getSize];
    
//    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"清理缓存(%.2fM)",tmpSize] : [NSString stringWithFormat:@"清理缓存(%.2fK)",tmpSize * 1024];
//    
//    NSLog(clearCacheName);
}

#pragma mark 清除用户信息本地缓存
-(void)clearUserInfoCache {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *userCacheKeys = (NSArray*)[userDefaults objectForKey:USER_CACHE_KEYS];
    if (userCacheKeys && userCacheKeys.count > 0) {
        for (NSString *key in userCacheKeys) {
            [userDefaults removeObjectForKey:key];
        }
    }
    [userDefaults removeObjectForKey:USER_CACHE_KEYS];
}
@end
