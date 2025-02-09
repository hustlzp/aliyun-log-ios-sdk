//
//  NetworkDiagnosisController.m
//  AliyunLogDemo
//
//  Created by gordon on 2021/12/27.
//

#import "NetworkDiagnosisController.h"
#import <AliyunLogProducer/AliyunLogProducer.h>

@interface NetworkDiagnosisController ()
@property(nonatomic, strong) UITextView *statusTextView;
@property (strong,nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray<NSString*> *endpoints;
@property (assign, atomic) long index;
@end

@implementation NetworkDiagnosisController

static NetworkDiagnosisController *selfClzz;

- (instancetype)init {
    self = [super init];
    if (self) {
        _endpoints = [[NSMutableArray alloc] init];
        [_endpoints addObject:@"cn-hangzhou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-hangzhou-finance.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shanghai.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shanghai-finance-1.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-qingdao.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-beijing.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-north-2-gov-1.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-zhangjiakou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-huhehaote.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-wulanchabu.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shenzhen.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-shenzhen-finance.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-heyuan.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-guangzhou.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-chengdu.log.aliyuncs.com"];
        [_endpoints addObject:@"cn-hongkong.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-northeast-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-2.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-3.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-6.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-southeast-5.log.aliyuncs.com"];
        [_endpoints addObject:@"me-east-1.log.aliyuncs.com"];
        [_endpoints addObject:@"us-west-1.log.aliyuncs.com"];
        [_endpoints addObject:@"eu-central-1.log.aliyuncs.com"];
        [_endpoints addObject:@"us-east-1.log.aliyuncs.com"];
        [_endpoints addObject:@"ap-south-1.log.aliyuncs.com"];
        [_endpoints addObject:@"eu-west-1.log.aliyuncs.com"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selfClzz = self;
    self.title = @"网络监控";
    [self initViews];
}

- (void) initViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self createLabel:@"参数: " andX:0 andY:0];

    DemoUtils *utils = [DemoUtils sharedInstance];
    NSString *parameters = [NSString stringWithFormat:@"endpoint: %@\nproject: %@\nlogstore:%@\naccessKeyId: %@\naccesskeySecret: %@\n",
                            utils.endpoint,
                            utils.project,
                            utils.logstore,
                            utils.accessKeyId,
                            utils.accessKeySecret];
    
    UILabel *label = [self createLabel:parameters andX:0 andY:SLCellHeight andWidth:SLScreenW - SLPadding * 2 andHeight:SLCellHeight * 5];
    label.numberOfLines = 0;
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentLeft;
    
    [[SLSNetworkDiagnosis sharedInstance] registerHttpCredentialDelegate:^NSURLCredential * _Nullable(NSString * _Nonnull url) {
        return [self getHttpCredential:url];
    }];
    
    [self createLabel:@"状态: " andX:0 andY:SLCellHeight * 5];
    
    self.statusTextView = [self createTextView:@"" andX:0 andY:SLCellHeight * 6 andWidth:(SLScreenW - SLPadding * 2) andHeight:(SLCellHeight * 4)];
    self.statusTextView.textAlignment = NSTextAlignmentLeft;
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    [self.statusTextView setEditable:NO];
    [self.statusTextView setContentOffset:CGPointMake(0, 0)];
    
    CGFloat lx = ((SLScreenW - SLPadding * 2) / 4 - SLCellWidth / 2);
    CGFloat rx = ((SLScreenW - SLPadding * 2) / 4 * 3 - SLCellWidth / 2);
    
    [[SLSNetworkDiagnosis sharedInstance] setMultiplePortsDetect:YES];
//    [[SLSNetworkDiagnosis sharedInstance] registerCallback:^(NSString * _Nonnull result) {
//        SLSLog(@"global callback: %@", result);
//    }];
    [[SLSNetworkDiagnosis sharedInstance] registerCallback2:^(SLSResponse * _Nonnull response) {
        SLSLog(@"global callback: %@", response.content);
    }];

    [self createButton:@"PING" andAction:@selector(ping) andX:lx andY:SLCellHeight * 11];
    [self createButton:@"TCPPING" andAction:@selector(tcpPing) andX:rx andY:SLCellHeight * 11];
    
    [self createButton:@"HTTPPING" andAction:@selector(httpPing) andX:lx andY:SLCellHeight * 12 + SLPadding];
    [self createButton:@"MTR" andAction:@selector(mtr) andX:rx andY:SLCellHeight * 12 + SLPadding];
    [self createButton:@"DNS" andAction:@selector(dns) andX:lx andY:SLCellHeight * 13 + SLPadding * 2 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
    
    [self createButton:@"AUTO" andAction:@selector(ato) andX:lx andY:SLCellHeight * 14 + SLPadding * 3 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
    [self createButton:@"动态更新配置" andAction:@selector(updateConfig) andX:lx andY:SLCellHeight * 15 + SLPadding * 4 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
    [self createButton:@"Extra" andAction:@selector(updateExtra) andX:lx andY:SLCellHeight * 16 + SLPadding * 5 andWidth:SLScreenW - (lx * 2 + SLPadding * 2) andHeight:SLCellHeight];
}

- (void) updateStatus: (NSString *)append {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *status = [NSString stringWithFormat:@"%@\n> %@", self.statusTextView.text, append];
        [self.statusTextView setText:status];
        [self.statusTextView scrollRangeToVisible:NSMakeRange(self->_statusTextView.text.length, 1)];
    });
}

- (void) ping {
    [self updateStatus:@"start ping..."];
    
    SLSPingRequest *request = [[SLSPingRequest alloc] init];
    request.domain = @"www.aliyun.com";
    // 可选参数
    request.context = @"<your ping context id>";
    request.parallel = YES;
    // 可选参数
    request.extention = @{
        @"custom_key": @"custom_value_ios"
    };
    [[SLSNetworkDiagnosis sharedInstance] ping2:request callback:^(SLSResponse * _Nonnull response) {
        NSLog(@"ping result: %@", response.content);
        [self updateStatus:[NSString stringWithFormat:@"ping result, data: %@", response.content]];
    }];
    
//    [[SLSNetworkDiagnosis sharedInstance] ping:@"www.aliyun.com" callback:^(NSString * _Nonnull result) {
//        NSLog(@"ping result: %@", result);
//        [self updateStatus:[NSString stringWithFormat:@"ping result, data: %@", result]];
//    }];
}

- (void) tcpPing {
    [self updateStatus:@"start tcpPing..."];
    SLSTcpPingRequest *request = [[SLSTcpPingRequest alloc] init];
    request.domain = @"www.aliyun.com";
    request.port = 80;
    // 可选参数
    request.context = @"<your tcpping context id>";
    // 可选参数
    request.extention = @{
        @"custom_key": @"custom_value_ios"
    };
    [[SLSNetworkDiagnosis sharedInstance] tcpPing2:request callback:^(SLSResponse * _Nonnull response) {
        [self updateStatus:[NSString stringWithFormat:@"tcpping result, data: %@", response.content]];
    }];
    
//    [[SLSNetworkDiagnosis sharedInstance] tcpPing:@"www.aliyun.com" port:80 callback:^(NSString * _Nonnull result) {
//        [self updateStatus:[NSString stringWithFormat:@"tcpping result, data: %@", result]];
//    }];
}

- (void) httpPing {
    [self updateStatus:@"start httpPing..."];
    
    SLSHttpRequest *request = [[SLSHttpRequest alloc] init];
    request.domain = @"https://demo.ne.aliyuncs.com";
    // 可选参数
    request.context = @"<your http context id>";
    request.headerOnly = YES;
    request.downloadBytesLimit = 128 * 1024; // 128KB
    request.credential = ^NSURLCredential * _Nullable(NSString * _Nonnull url) {
        return [self getHttpCredential:url];
    };
    // 可选参数
    request.extention = @{
        @"custom_key": @"custom_value_ios"
    };

    [[SLSNetworkDiagnosis sharedInstance] http2:request callback:^(SLSResponse * _Nonnull response) {
        [self updateStatus:[NSString stringWithFormat:@"http result, data: %@", response.content]];
    }];
    
    
//    [[SLSNetworkDiagnosis sharedInstance] http:@"https://demo.ne.aliyuncs.com" callback:^(NSString * _Nonnull result) {
//        [self updateStatus:[NSString stringWithFormat:@"http result, data: %@", result]];
//    } credential:^NSURLCredential * _Nullable(NSString * _Nonnull url) {
//        return [self getHttpCredential:url];
//    }];
}

- (void) mtr {
    [self updateStatus:@"start mtr..."];
    SLSMtrRequest *request = [[SLSMtrRequest alloc] init];
    request.domain = @"www.aliyun.com";
    // 可选参数
    request.context = @"<your mtr context id>";
    request.parallel = YES;
    request.protocol = SLS_MTR_PROROCOL_ALL;
    // 可选参数
    request.extention = @{
        @"custom_key": @"custom_value_ios"
    };

    [[SLSNetworkDiagnosis sharedInstance] mtr2:request callback:^(SLSResponse * _Nonnull response) {
        [self updateStatus:[NSString stringWithFormat:@"mtr result, data: %@", response.content]];
    }];
    
//    [[SLSNetworkDiagnosis sharedInstance] mtr:@"www.aliyun.com" callback:^(NSString * _Nonnull result) {
//        [self updateStatus:[NSString stringWithFormat:@"mtr result, data: %@", result]];
//    }];
}

- (void) dns {
    [self updateStatus:@"start dns..."];
    SLSDnsRequest *request = [[SLSDnsRequest alloc] init];
    request.domain = @"www.aliyun.com";
    // 可选参数
    request.context = @"<your dns context id>";
    // 可选参数
    request.extention = @{
        @"custom_key": @"custom_value_ios"
    };
    
    [[SLSNetworkDiagnosis sharedInstance] dns2:request callback:^(SLSResponse * _Nonnull response) {
        [self updateStatus:[NSString stringWithFormat:@"dns result, data: %@", response.content]];
    }];
    
//    [[SLSNetworkDiagnosis sharedInstance] dns:@"www.aliyun.com" callback:^(NSString * _Nonnull result) {
//        [self updateStatus:[NSString stringWithFormat:@"dns result, data: %@", result]];
//    }];
}

- (void) navToPolicy {
//    [self.navigationController pushViewController:[[NetworkDiagnosisPolicyController alloc]init] animated:YES];
}

- (void) ato {
    [self updateStatus:@"start mtr..."];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(atoMethods) userInfo:nil repeats:YES];
}

- (void) atoMethods {
    [self ping];
    [self tcpPing];
    [self httpPing];
    [self mtr];
}

- (void) updateConfig {
    SLSCredentials *credentials = [SLSCredentials credentials];
    credentials.networkDiagnosisCredentials = [credentials createNetworkDiagnosisCredentials];
    credentials.networkDiagnosisCredentials.accessKeyId = @"";
    credentials.networkDiagnosisCredentials.accessKeySecret = @"";
    
    [[SLSCocoa sharedInstance] setCredentials:credentials];
}

- (void) updateExtra {
    _index += 1;
    
    [[SLSCocoa sharedInstance] setExtra:[NSString stringWithFormat:@"extra_key_%ld", _index] value:[NSString stringWithFormat:@"extra_value_%ld", _index]];
    [[SLSCocoa sharedInstance] setExtra:[NSString stringWithFormat:@"extra_dict_key_%ld", _index] dictValue:@{
        [NSString stringWithFormat:@"extra_dict_key_%ld", _index]: [NSString stringWithFormat:@"extra_dict_value_%ld", _index]
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timer && [_timer isValid]) {
        [_timer invalidate];
    }
}

-(NSURLCredential*) getHttpCredential:(NSString*)url {
    if (![url containsString:@"demo.ne.aliyuncs.com"]) {
        return nil;
    }
    
    NSString *p12WithBase64 = @"";
    NSData *p12Data = [[NSData alloc] initWithBase64EncodedString:p12WithBase64 options:0];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)p12Data;
        
    SecIdentityRef identity = NULL;
    NSString *pass = @"123";
    OSStatus status = [self extractIdentity:inPKCS12Data identity:&identity pass:pass];
    if(status != 0 || identity == NULL) {
        return nil;
    }
        
        SecCertificateRef certificate = NULL;
        SecIdentityCopyCertificate (identity, &certificate);
        const void *certs[] = {certificate};
        CFArrayRef arrayOfCerts = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
        
        // NSURLCredentialPersistenceForSession:创建URL证书,在会话期间有效
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray*)arrayOfCerts persistence:NSURLCredentialPersistenceForSession];
        
        if(certificate) {
            CFRelease(certificate);
        }
        
        if (arrayOfCerts) {
            CFRelease(arrayOfCerts);
        }
    if (credential) {
        return [credential copy];
    }
    
    return nil;
}

// 提取身份identity
- (OSStatus)extractIdentity:(CFDataRef)inP12Data identity:(SecIdentityRef*)identity pass:(NSString *)pass {
    
    CFStringRef password = (__bridge CFStringRef)(pass);//证书密码
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import(inP12Data, options, &items);
    if (securityError == 0)
    {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}

@end
