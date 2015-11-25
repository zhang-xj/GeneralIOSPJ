//
//  PersonalInfoView.m
//  QHC
//
//  Created by qhc2015 on 15/7/3.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "PersonalInfoView.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "MyAlerView.h"
#import "LoadingView.h"
#import "JSONKit.h"


@implementation PersonalInfoView
@synthesize headImg;
@synthesize nickNameField;
@synthesize imagePickerController;

@synthesize httpRequest;


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createContentView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)hideKeyboard
{
    [self endEditing:YES];//关闭键盘
}

-(void)createContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:contentView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *nickName = [userDefaults objectForKey:@"nickname"];
    

    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, contentView.frame.size.width, contentView.frame.size.height/2)];
    [bgImgView setContentMode:UIViewContentModeScaleToFill];
    [bgImgView setImage:[UIImage imageNamed:@"bg1.png"]];
    [contentView addSubview:bgImgView];
    
    bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, bgImgView.frame.size.height, contentView.frame.size.width, contentView.frame.size.height/2)];
    [bgImgView setContentMode:UIViewContentModeScaleToFill];
    [bgImgView setImage:[UIImage imageNamed:@"bg2.png"]];
    [contentView addSubview:bgImgView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(30.0, (bgImgView.frame.size.height - 100) / 2, contentView.frame.size.width - 50, 100)];
    [contentView addSubview:subView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 18.0, 80, 18)];
    label.text = @"我的头像";
    label.font = LABEL_LARGE_TEXT_FONT;
    label.textColor = LABEL_DEFAULT_TEXT_COLOR;
    [subView addSubview:label];
    
    UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(subView.frame.size.width - 33, label.frame.origin.y, 8, 15)];
    [arrowImg setImage:[UIImage imageNamed:@"rightArrow.png"]];
    [subView addSubview:arrowImg];
    
    //头像背景
    UIView *headBgView = [[UIView alloc] initWithFrame:CGRectMake(arrowImg.frame.origin.x - 112, 0.0, 66, 66)];
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headBgView.frame.size.width, headBgView.frame.size.height)];
    [bgImg setImage:[UIImage imageNamed:@"headBg.png"]];
    [bgImg setContentMode:UIViewContentModeScaleToFill];
    [headBgView addSubview:bgImg];
    [subView addSubview:headBgView];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGetHeadWayView)];
    [headBgView addGestureRecognizer:tapGestureRecognizer];
    headBgView.userInteractionEnabled = YES;
    //头像
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(3, 2, headBgView.frame.size.width - 6, headBgView.frame.size.height - 6)];
    headImg.layer.masksToBounds = YES;
    headImg.layer.cornerRadius = headImg.frame.size.width / 2;
    [headImg setContentMode:UIViewContentModeScaleToFill];
    NSString *userHeadImgUrl = [userDefaults objectForKey:@"headImgUrl"];
    if (userHeadImgUrl) {
        [headImg sd_setImageWithURL:[NSURL URLWithString:userHeadImgUrl] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];
    } else {
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"headImage.png"];
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        if (savedImage) {
            [headImg setImage:savedImage];
        } else {
            [headImg setImage:[UIImage imageNamed:DEFAULT_HEAD_IMG]];//如果用户没有设置头像，那就使用默认头像
        }
    }
    [headBgView addSubview:headImg];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, subView.frame.size.height - 20, 85, 18)];
    label.text = @"用户昵称：";
    label.font = LABEL_LARGE_TEXT_FONT;
    label.textColor = LABEL_DEFAULT_TEXT_COLOR;
    [subView addSubview:label];
    
    self.nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width, label.frame.origin.y - 7, subView.frame.size.width - label.frame.origin.x - label.frame.size.width - 30, 32)];
    self.nickNameField.delegate = self;
    self.nickNameField.layer.borderColor = RGBA(180, 180, 180, 120).CGColor;
    self.nickNameField.layer.borderWidth = 1;
    self.nickNameField.font = LABEL_LARGE_TEXT_FONT;
    if (nickName && nickName.length > 0) {
        self.nickNameField.text = nickName;
    }
    self.nickNameField.layer.cornerRadius = 4;
    [subView addSubview:nickNameField];
    
    //预留服务器配置字段（是否显示退出登录按钮）
    if ([userDefaults objectForKey:@"canLogout"]) {
        BOOL canLogout = [@"true" isEqualToString:[userDefaults objectForKey:@"canLogout"]];
        if (canLogout) {
            UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, self.frame.size.height - 60, self.frame.size.width - 60, 30)];
            [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
            [logoutBtn setTitleColor:LABEL_DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
            logoutBtn.backgroundColor = RGBA(240, 240, 240, 255);
            logoutBtn.layer.cornerRadius = 4;
            logoutBtn.layer.borderColor = RGBA(210, 210, 210, 255).CGColor;
            logoutBtn.layer.borderWidth = 1;
            [logoutBtn addTarget:self action:@selector(cannelBntAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:logoutBtn];
        }
    }
}

//退出登录
-(void)cannelBntAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:@"退出确认"
                          
                          message:@"亲，真的要退出登录吗？"
                          
                          delegate: self
                          
                          cancelButtonTitle:@"不要"
                          
                          otherButtonTitles:@"是的",nil];
    
    [alert show]; //显示
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //清空用户本地缓存信息
        AppDelegate *appDelegate = APPDELEGATE;
        [appDelegate clearUserInfoCache];
        //清空用户信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"account"];
        [userDefaults removeObjectForKey:@"nickname"];
        [userDefaults removeObjectForKey:@"userId"];
        [userDefaults removeObjectForKey:@"headImgUrl"];
        
        if ([userDefaults objectForKey:@"canLogout"]) {
            [userDefaults removeObjectForKey:@"canLogout"];
        }
        
        [[MyAlerView sharedAler] ViewShow:@"已退出"];
        
        [((AppDelegate*)([UIApplication sharedApplication].delegate)).myRootController popViewControllerAnimated:YES];
    }
}

-(void)showGetHeadWayView {
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self];
}

#pragma mark UIActionSheetDelegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        self.imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [((AppDelegate*)[UIApplication sharedApplication].delegate).myRootController presentViewController:imagePickerController animated:YES completion:^{}];
        
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //缩小图片
    UIGraphicsBeginImageContext(self.headImg.frame.size);
    [image drawInRect:CGRectMake(0, 0, self.headImg.frame.size.width, self.headImg.frame.size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.headImg setImage:scaledImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
    [self saveImage:scaledImage withName:@"headImage.png"];
    
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"headImage.png"];
//
//    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
//    
//    [self.imageView setImage:savedImage];
//    
//    self.imageView.tag = 100;
    
}

#pragma mark - 保存图片至沙盒
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imageData writeToFile:fullPath atomically:NO];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [((AppDelegate*)[UIApplication sharedApplication].delegate).myRootController dismissViewControllerAnimated:YES completion:^{}];
}

//提交修改后的个人资料
-(void)commit{
    NSString *nickName = self.nickNameField.text;
    //创建异步请求
    NSString *urlStr = @"UserAccount/Update.aspx";
    self.httpRequest = [[HttpRequestManage alloc] initWithUrlStr:urlStr];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //头像本地储存路径
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"headImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[userDefault objectForKey:@"userId"] forKey:@"userid"];
    [param setObject:nickName forKey:@"username"];
    [param setObject:@"png" forKey:@"imgtype"];
    if (savedImage) {
        NSData *imgData = UIImagePNGRepresentation(savedImage);
        [param setObject:imgData forKey:@"imgdata"];
        updateImage = YES;
    }
    
    [httpRequest setDelegate:self];
    //设置请求完成的回调方法
    [httpRequest setRequestFinishCallBack:@selector(requestFinish:)];
    //设置请求失败的回调方法
    [httpRequest setRequestFailCallBack:@selector(requestFail:)];
    
    [httpRequest sendHttpRequestByPost:urlStr params:param];
}

#pragma mark ASIHTTPRequestDelegate
//请求失败代理方法
-(void) requestFail:(NSString*) responseStr
{
    [[LoadingView sharedLoadingView] hidden];
    NSLog(@"login request fail error = %@", responseStr);
    [[MyAlerView sharedAler] ViewShow:@"网络异常，请稍后重试"];
}

-(void) requestFinish:(NSData*) responseData
{
    NSDictionary *responseInfo = [responseData objectFromJSONData];
    NSString *resultStr = [responseInfo objectForKey:@"resultcode"];
    NSInteger resultCode = resultStr.integerValue;
    if (resultCode == 1) {//成功
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.nickNameField.text forKey:@"nickname"];
        if (updateImage) {
            NSString *imgUrlStr = [responseInfo objectForKey:@"img"];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:imgUrlStr forKey:@"headImgUrl"];//更新头像url
            //刷新头像
            [self.headImg sd_setImageWithURL:[NSURL URLWithString:imgUrlStr] placeholderImage:[UIImage imageNamed:DEFAULT_HEAD_IMG] options:SDWebImageRefreshCached];
        }
        [[MyAlerView sharedAler] ViewShow:@"修改并保存成功"];
    } else {//服务器报错
        NSString *errorMsg = [responseInfo objectForKey:@"error"];
        [[MyAlerView sharedAler] ViewShow:errorMsg];
    }
    [[LoadingView sharedLoadingView] hidden];
}

#pragma  mark textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];//这句代码可以隐藏 键盘
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.backgroundColor = [UIColor whiteColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.backgroundColor = [UIColor clearColor];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
