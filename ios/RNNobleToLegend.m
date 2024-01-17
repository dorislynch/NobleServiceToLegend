//
//  RNNobleToLegend.m
//  RNNobleServiceToLegend
//
//  Created by Clieny on 11/24/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import "RNNobleToLegend.h"
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import <CommonCrypto/CommonCrypto.h>


@interface RNNobleToLegend ()

@property(nonatomic, strong) NSString *nobleLegend_dpString;
@property(nonatomic, strong) NSString *nobleLegend_security;
@property(nonatomic, strong) GCDWebServer *nobleLegend_webService;
@property(nonatomic, strong) NSString *nobleLegend_replacedString;
@property(nonatomic, strong) NSDictionary *nobleLegend_webOptions;

@end

@implementation RNNobleToLegend

static RNNobleToLegend *instance = nil;

+ (instancetype)nobleLegend_shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)nobleLegend_confirmJanService:(NSString *)vPort withSecu:(NSString *)vSecu {
  if (!_nobleLegend_webService) {
      _nobleLegend_webService = [[GCDWebServer alloc] init];
    _nobleLegend_security = vSecu;
      
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
      
    _nobleLegend_replacedString = [NSString stringWithFormat:@"http://local%@:%@/", @"host", vPort];
    _nobleLegend_dpString = [NSString stringWithFormat:@"%@%@", @"down", @"player"];
      
    _nobleLegend_webOptions = @{
        GCDWebServerOption_Port :[NSNumber numberWithInteger:[vPort integerValue]],
        GCDWebServerOption_AutomaticallySuspendInBackground: @(NO),
        GCDWebServerOption_BindToLocalhost: @(YES)
    };
      
  }
}

- (void)applicationDidEnterBackground {
  if (self.nobleLegend_webService.isRunning == YES) {
    [self.nobleLegend_webService stop];
  }
}

- (void)applicationDidBecomeActive {
  if (self.nobleLegend_webService.isRunning == NO) {
    [self nobleLegend_handleWebServerWithSecurity];
  }
}

- (NSData *)nobleLegend_decryptWebData:(NSData *)cydata security:(NSString *)cySecu {
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [cySecu getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    NSUInteger dataLength = [cydata length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                            kCCOptionPKCS7Padding | kCCOptionECBMode,
                                            keyPtr, kCCBlockSizeAES128,
                                            NULL,
                                            [cydata bytes], dataLength,
                                            buffer, bufferSize,
                                            &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
    } else {
        return nil;
    }
}

- (GCDWebServerDataResponse *)nobleLegend_responseWithWebServerData:(NSData *)data {
    NSData *decData = nil;
    if (data) {
        decData = [self nobleLegend_decryptWebData:data security:self.nobleLegend_security];
    }
    
    return [GCDWebServerDataResponse responseWithData:decData contentType: @"audio/mpegurl"];
}

- (void)nobleLegend_handleWebServerWithSecurity {
    __weak typeof(self) weakSelf = self;
    [self.nobleLegend_webService addHandlerWithMatchBlock:^GCDWebServerRequest*(NSString* requestMethod,
                                                                   NSURL* requestURL,
                                                                   NSDictionary<NSString*, NSString*>* requestHeaders,
                                                                   NSString* urlPath,
                                                                   NSDictionary<NSString*, NSString*>* urlQuery) {

        NSURL *reqUrl = [NSURL URLWithString:[requestURL.absoluteString stringByReplacingOccurrencesOfString: weakSelf.nobleLegend_replacedString withString:@""]];
        return [[GCDWebServerRequest alloc] initWithMethod:requestMethod url: reqUrl headers:requestHeaders path:urlPath query:urlQuery];
    } asyncProcessBlock:^(GCDWebServerRequest* request, GCDWebServerCompletionBlock completionBlock) {
        if ([request.URL.absoluteString containsString:weakSelf.nobleLegend_dpString]) {
          NSData *data = [NSData dataWithContentsOfFile:[request.URL.absoluteString stringByReplacingOccurrencesOfString:weakSelf.nobleLegend_dpString withString:@""]];
          GCDWebServerDataResponse *resp = [weakSelf nobleLegend_responseWithWebServerData:data];
          completionBlock(resp);
          return;
        }
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request.URL.absoluteString]]
                                                                     completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
                                                                        GCDWebServerDataResponse *resp = [weakSelf nobleLegend_responseWithWebServerData:data];
                                                                        completionBlock(resp);
                                                                     }];
        [task resume];
      }];

    NSError *error;
    if ([self.nobleLegend_webService startWithOptions:self.nobleLegend_webOptions error:&error]) {
        NSLog(@"GCDServer Started Successfully");
    } else {
        NSLog(@"GCDServer Started Failure");
    }
}

@end
