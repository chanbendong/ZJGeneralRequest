//
//  ZJGeneralRequest.h
//  ZJGeneralRequest
//
//  Created by 吴孜健 on 2018/2/8.
//  Copyright © 2018年 吴孜健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YTKNetwork/YTKNetwork.h>

/**<请求数据序列化类型*/
typedef NS_ENUM(NSUInteger, ZJReqSerializerType) {
    ZJReqSerializerTypeHTTP,
    ZJReqSerializerTypeJSON,
};
/**<响应数据序列化类型*/
typedef NS_ENUM(NSUInteger, ZJResSerializerType) {
    ZJResSerializerTypeHTTP,
    ZJResSerializerTypeJSON,
};

/**<mimeType类型*/
typedef NS_ENUM(NSUInteger, ZJReqMimeType) {
    ZJReqMimeTypeFormData,
    ZJReqMimeTypeJPEG,
    ZJReqMimeTypePNG,
};

/**<上传图片类型*/
typedef NS_ENUM(NSUInteger, ZJUploadImageType) {
    ZJUploadImageTypeOther,
    ZJUploadImageTypeJPEG,
    ZJUploadImageTypePNG,
};

@interface ZJGeneralRequest : YTKRequest

@property (nonatomic, assign) ZJResSerializerType resSerializerType;

#pragma mark - 普通文本请求


/**
 指定请求类型及方式

 @param params 参数
 @param api host
 @param method 请求方法
 @param reqSerializerType 请求解析方式
 @return 响应数据
 */
+ (id)requestWithParams:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method ReqSerializerType:(ZJReqSerializerType)reqSerializerType;


+ (id)requestWithParams:(NSDictionary *)params FormDataApi:(NSString *)formDataApi Method:(NSString *)method;/**<form-data请求*/

+ (id)requestWithParams:(NSDictionary *)params JsonDataApi:(NSString *)jsonDataApi Method:(NSString *)method;/**<json-data请求*/

+ (id)requestWithParams:(NSDictionary *)params FormDataApi:(NSString *)formDataApi;/**<form-data get请求*/

+ (id)requestWithParams:(NSDictionary *)params JsonDataApi:(NSString *)jsonDataApi;/**<json-data get请求*/

#pragma mark - 文件上传


+ (id)requestWithImage:(UIImage *)image ImgKey:(NSString *)imgKey Api:(NSString *)api Method:(NSString *)method CompressQuality:(CGFloat)compressQuality;/**<单图上传，需指定所有参数*/

+ (id)requestWithJPEG:(UIImage *)jpegImage ImgKey:(NSString *)imgKey Api:(NSString *)api Method:(NSString *)method;/**<jpeg单图片上传，默认压缩率*/

+ (id)requestWithFileArray:(NSArray *)fileArray Name:(NSString *)name Filekey:(NSString *)fileKey MimeType:(ZJReqMimeType)MimeType ImageUploadType:(ZJUploadImageType)imageUploadType CompressQuality:(CGFloat)compressQuality Params:(NSDictionary *)params Api:(NSString *)api Method:(NSString *)method;/**<多文件上传*/

#pragma mark -请求并得到相应

- (void)requestReturnClass:(NSString *)returnClass Success:(void (^)(id res))success Failed:(void (^)(id errCode, id errMsg))failed;





@end
