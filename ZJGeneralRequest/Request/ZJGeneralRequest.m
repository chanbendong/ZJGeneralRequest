//
//  ZJGeneralRequest.m
//  ZJGeneralRequest
//
//  Created by 吴孜健 on 2018/2/8.
//  Copyright © 2018年 吴孜健. All rights reserved.
//

#import "ZJGeneralRequest.h"
#import <YYModel.h>
#import <AFNetworking.h>

#pragma mark - 请求方式
#define kPOST_METHOD @"POST"
#define kGET_METHOD @"GET"
#define kDELETE_METHOD @"DELETE"
#define kPUT_METHOD @"PUT"

static NSString *const kImgMimeType_JPEG = @"image/jpeg";
static NSString *const kImgMimeType_PNG = @"image/png";
static NSString *const kMultipartMimeType_Formdata = @"multipart/form-data";
static NSString *const kFileKey_Default = @"file";
static CGFloat const kImgCompressQuality = 0.5;

@implementation ZJGeneralRequest
{
    NSDictionary *_params;
    NSString *_api;
    NSString *_requestMethod;
    ZJReqSerializerType _reqSerializerType;
    
    BOOL _isFileUpload;
    //文件/图片上传参数
    NSString *_fileName;
    NSString *_fileKey;
    ZJReqMimeType _fileMimeType;
    ZJUploadImageType _imgUploadType;
    NSString *_fileMimeTypeStr;/**<文件类型*/
    NSMutableArray *_listFileArray;/**<多个文件*/
    CGFloat _imgCompressionQuality;/**<自定义图片压缩率*/
}

+ (id)requestWithParams:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method ReqSerializerType:(ZJReqSerializerType)reqSerializerType
{
    return [[ZJGeneralRequest alloc]initWithParams:params Api:api Method:method RequestSerializerType:reqSerializerType];
}


+ (id)requestWithParams:(NSDictionary *)params FormDataApi:(NSString *)formDataApi Method:(NSString *)method
{
    return [[ZJGeneralRequest alloc]initWithParams:params Api:formDataApi Method:method RequestSerializerType:ZJReqSerializerTypeHTTP];
}

+ (id)requestWithParams:(NSDictionary *)params JsonDataApi:(NSString *)jsonDataApi Method:(NSString *)method
{
    return [[ZJGeneralRequest alloc]initWithParams:params Api:jsonDataApi Method:method RequestSerializerType:ZJReqSerializerTypeJSON];
}

+ (id)requestWithParams:(NSDictionary *)params FormDataApi:(NSString *)formDataApi
{
    return [[ZJGeneralRequest alloc]initWithParams:params Api:formDataApi Method:kGET_METHOD RequestSerializerType:ZJReqSerializerTypeHTTP];
}

+ (id)requestWithParams:(NSDictionary *)params JsonDataApi:(NSString *)jsonDataApi
{
    return [[ZJGeneralRequest alloc]initWithParams:params Api:jsonDataApi Method:kGET_METHOD RequestSerializerType:ZJReqSerializerTypeJSON];
}

#pragma mark -文件上传接口

+ (id)requestWithImage:(UIImage *)image ImgKey:(NSString *)imgKey Api:(NSString *)api Method:(NSString *)method CompressQuality:(CGFloat)compressQuality
{
    return [[ZJGeneralRequest alloc]initWithFileArray:@[image] Name:imgKey FileKey:imgKey MimeType:ZJReqMimeTypeFormData ImgType:ZJUploadImageTypeJPEG CompressQuality:compressQuality params:nil Api:api Method:method];
}

+ (id)requestWithJPEG:(UIImage *)jpegImage ImgKey:(NSString *)imgKey Api:(NSString *)api Method:(NSString *)method
{
    return [[ZJGeneralRequest alloc]initWithFileArray:@[jpegImage] Name:imgKey FileKey:imgKey MimeType:ZJReqMimeTypeFormData ImgType:ZJUploadImageTypeJPEG CompressQuality:kImgCompressQuality params:nil Api:api Method:method];
}

+ (id)requestWithFileArray:(NSArray *)fileArray Name:(NSString *)name Filekey:(NSString *)fileKey MimeType:(ZJReqMimeType)MimeType ImageUploadType:(ZJUploadImageType)imageUploadType CompressQuality:(CGFloat)compressQuality Params:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method
{
    return [[ZJGeneralRequest alloc]initWithFileArray:fileArray Name:name FileKey:fileKey MimeType:MimeType ImgType:imageUploadType CompressQuality:compressQuality params:params Api:api Method:method];
}


#pragma mark -请求对象处理


/**
 文本请求

 @param params 参数
 @param api api
 @param method 请求方法
 @param reqSerializerType 请求数据序列化
 @return self
 */
- (id)initWithParams:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method RequestSerializerType:(ZJReqSerializerType)reqSerializerType
{
    if (self = [super init]) {
        params = params?params:[NSMutableDictionary dictionary];
        _isFileUpload = NO;
        _params = params;
        _api = api;
        _requestMethod = method;
        _reqSerializerType = reqSerializerType;
    }
    return self;
}

- (id)initWithFileArray:(NSArray *)fileArray Name:(NSString *)name FileKey:(NSString *)fileKey MimeType:(ZJReqMimeType)mimeType ImgType:(ZJUploadImageType)imgUploadType CompressQuality:(CGFloat)compressQuality params:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method
{
    if (self = [super init]) {
        _isFileUpload = YES;
        _params = [params mutableCopy];
        _api = api;
        _requestMethod = method;
        _listFileArray = [fileArray mutableCopy];
        _fileKey = fileKey.length>0?fileKey:kFileKey_Default;
        _fileName = name.length>0?name:_fileKey;
        _fileMimeType = mimeType;
        _fileMimeTypeStr = kMultipartMimeType_Formdata;//默认form-data上传
        _isFileUpload = imgUploadType;
        _imgCompressionQuality = compressQuality>0?compressQuality:kImgCompressQuality;
    }
    return self;
}

#pragma mark -请求并得到相应
- (void)requestReturnClass:(NSString *)returnClass Success:(void (^)(id))success Failed:(void (^)(id, id))failed
{
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"【api: %@】 json:%@",request.requestUrl, request.responseString);;
        if (success) {
            if (returnClass) {
                success([self reflectModelFromResult:request.responseString ModelName:returnClass]);
            }else{
                success(nil);
            }
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSLog(@"url : 【%@】 response: %@",_api, request.responseString);
    }];
}

#pragma mark -数据解析

- (id)reflectModelFromResult:(NSString *)result ModelName:(NSString *)modelName
{
    NSLog(@"result : %@", result);
    id obj = nil;
    if (result && ![result isKindOfClass:[NSNull class]] && ![result isEqualToString:@""]) {
        id modelClass = NSClassFromString(modelName);
        obj = [self jsonTransformToObject:result];
        if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) {
            obj = [NSArray yy_modelArrayWithClass:modelClass json:result];
        }else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSMutableDictionary class]]){
            obj = [NSDictionary yy_modelDictionaryWithClass:modelClass json:result];
        }else{
            obj = result;
        }
    }
    return obj;
}

- (id)jsonTransformToObject:(id)json
{
    if ([json isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[((NSString *)json) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    } else if ([json isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)json options:kNilOptions error:nil];
    }
    return [NSObject yy_modelWithJSON:json];
}

#pragma mark -请求参数设置
//设置头部
//- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary
//{
//    return nil;
//}

//multipart-formdata
- (AFConstructingBlock)constructingBodyBlock
{
    if (_isFileUpload) {
        return ^(id<AFMultipartFormData> formData){
            if (_fileMimeType == ZJReqMimeTypeJPEG) {
                _fileMimeTypeStr = kImgMimeType_JPEG;
            }else if (_fileMimeType == ZJReqMimeTypePNG){
                _fileMimeTypeStr = kImgMimeType_PNG;
            }
            
            if (_listFileArray && _listFileArray.count != 0) {
                for (id originData in _listFileArray) {
                    [self formData:formData AppendFileData:originData
                     ];
                }
            }
            if (_params) {
                for (NSString *key in _params) {
                    if ([_params[key] isKindOfClass:[NSNumber class]]) {
                        NSData *convertData = [NSKeyedArchiver archivedDataWithRootObject:_params[key]];
                        [formData appendPartWithFormData:convertData name:key];
                    }else{
                        [formData appendPartWithFormData:[_params[key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    }
                }
            }
        };
    }else{
        return nil;
    }
}

- (void)formData:(id<AFMultipartFormData>)formData AppendFileData:(id)originData
{
    NSData *data = nil;
    if (_imgUploadType == ZJUploadImageTypeJPEG) {
        data = UIImageJPEGRepresentation(originData, _imgCompressionQuality);
        _fileName = [_fileName stringByAppendingString:@".jpg"];
    }else if (_imgUploadType == ZJUploadImageTypePNG){
        data = UIImagePNGRepresentation(originData);
        _fileName = [_fileName stringByAppendingString:@".png"];
    }else{
        data = originData;
    }
    
    [formData appendPartWithFileData:data name:_fileKey fileName:_fileName mimeType:_fileMimeTypeStr];
}

- (id)requestArgument
{
    return _params;
}

- (NSString *)requestUrl
{
    return _api;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return 20;
}

- (YTKRequestMethod)requestMethod
{
    if ([_requestMethod isEqualToString:kGET_METHOD]) {
        return YTKRequestMethodGET;
    }else if ([_requestMethod isEqualToString:kPOST_METHOD]){
        return YTKRequestMethodPOST;
    }else if ([_requestMethod isEqualToString:kPUT_METHOD]){
        return YTKRequestMethodPUT;
    }else if ([_requestMethod isEqualToString:kDELETE_METHOD]){
        return YTKRequestMethodDELETE;
    }
    return YTKRequestMethodGET;
}

- (YTKRequestSerializerType)requestSerializerType
{
    if (_reqSerializerType == ZJReqSerializerTypeHTTP) {
        return YTKRequestSerializerTypeHTTP;
    }else{
        return YTKRequestSerializerTypeJSON;
    }
}

- (YTKResponseSerializerType)responseSerializerType
{
    if (_resSerializerType == ZJResSerializerTypeHTTP) {
        return YTKResponseSerializerTypeHTTP;
    }else{
        return YTKResponseSerializerTypeJSON;
    }
}

@end
