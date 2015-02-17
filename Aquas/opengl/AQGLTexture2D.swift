//
//  AQGLTexture2D.swift
//  Aquas
//
//  Created by Qiang on 2/14/15.
//  Copyright (c) 2015 gigakuma. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

func nextPower2(x: CUnsignedLong) -> CUnsignedLong {
    var v = x
    v = v - 1
    v = v | (v >> 1)
    v = v | (v >> 2)
    v = v | (v >> 4)
    v = v | (v >> 8)
    v = v | (v >> 16)
    return v + 1
}

/// The pixel format of OpenGL textures. There are two kinds of format, normal and compressed.
/// The property 'compressed' tells you which kind the format is.
public enum AQGLTexture2DPixelFormat {
    case Automatic
    // normal format
    case RGBA8
    case RGBA4
    case RGBA5551
    case RGB8
    case RGB565
    case L8
    case A8
    case LA88
    // compressed format
    case RGB_PVRTC2
    case RGB_PVRTC4
    case RGBA_PVRTC2
    case RGBA_PVRTC4
    case R11_EAC
    case SR11_EAC
    case RG11_EAC
    case SRG11_EAC
    case RGB8_ETC2
    case SRGB8_ETC2
    case RGB8_PUNCHTHROUGH_ALPHA1_ETC2
    case SRGB8_PUNCHTHROUGH_ALPHA1_ETC2
    case RGBA8_ETC2_EAC
    case SRGB8_ALPHA8_ETC2_EAC
    
    var formats: (internalFormat: GLint, format: GLenum, type: GLenum) {
        switch self {
        case .RGBA8:
            return (GLint(GL_RGBA), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE))
        case .RGB8:
            return (GLint(GL_RGB), GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE))
        case .RGBA4:
            return (GLint(GL_RGBA), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_SHORT_4_4_4_4))
        case .RGBA5551:
            return (GLint(GL_RGBA), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_SHORT_5_5_5_1))
        case .RGB565:
            return (GLint(GL_RGB), GLenum(GL_RGB), GLenum(GL_UNSIGNED_SHORT_5_6_5))
        case .L8:
            return (GLint(GL_LUMINANCE), GLenum(GL_LUMINANCE), GLenum(GL_UNSIGNED_BYTE))
        case .A8:
            return (GLint(GL_ALPHA), GLenum(GL_ALPHA), GLenum(GL_UNSIGNED_BYTE))
        case .LA88:
            return (GLint(GL_LUMINANCE_ALPHA), GLenum(GL_LUMINANCE_ALPHA), GLenum(GL_UNSIGNED_BYTE))
        default:
            return (0, 0, 0)
        }
    }
    
    var compressedFormats: (internalFormat: GLenum, imageSizeScale: UInt) {
        switch self {
        case .RGB_PVRTC2:
            return (GLenum(GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG), 4)
        case .RGB_PVRTC4:
            return (GLenum(GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG), 8)
        case .RGBA_PVRTC2:
            return (GLenum(GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG), 4)
        case .RGBA_PVRTC4:
            return (GLenum(GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG), 8)
        // avaliable in OpenGLES 3.0
        case .R11_EAC:
            return (GLenum(GL_COMPRESSED_R11_EAC), 8)
        case .SR11_EAC:
            return (GLenum(GL_COMPRESSED_SIGNED_R11_EAC), 8)
        case .RG11_EAC:
            return (GLenum(GL_COMPRESSED_RG11_EAC), 16)
        case .SRG11_EAC:
            return (GLenum(GL_COMPRESSED_SIGNED_R11_EAC), 16)
        case .RGB8_ETC2:
            return (GLenum(GL_COMPRESSED_RGB8_ETC2), 8)
        case .SRGB8_ETC2:
            return (GLenum(GL_COMPRESSED_SRGB8_ETC2), 8)
        case .RGB8_PUNCHTHROUGH_ALPHA1_ETC2:
            return (GLenum(GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2), 8)
        case .SRGB8_PUNCHTHROUGH_ALPHA1_ETC2:
            return (GLenum(GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2), 8)
        case .RGBA8_ETC2_EAC:
            return (GLenum(GL_COMPRESSED_RGBA8_ETC2_EAC), 16)
        case .SRGB8_ALPHA8_ETC2_EAC:
            return (GLenum(GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC), 16)
        default:
            return (0, 0)
        }
    }
    
    public var compressed: Bool {
        switch self {
        case .RGB_PVRTC2, .RGB_PVRTC4,
            .RGBA_PVRTC2, .RGBA_PVRTC4,
            .R11_EAC, .SR11_EAC,
            .RG11_EAC, .SR11_EAC,
            .RGB8_ETC2, .SRGB8_ETC2,
            .RGB8_PUNCHTHROUGH_ALPHA1_ETC2, .SRGB8_PUNCHTHROUGH_ALPHA1_ETC2,
            .RGBA8_ETC2_EAC, .SRGB8_ALPHA8_ETC2_EAC:
            return true
        default:
            return false
        }
    }
}

/// OpenGL texture.
public class AQGLTexture2D : AQGLObject {
    
    let width: UInt
    let height: UInt
    let maxS: Float
    let maxT: Float
    let format: AQGLTexture2DPixelFormat
    
    public init(data: UnsafePointer<Void>, pixelFormat: AQGLTexture2DPixelFormat, width: UInt, height: UInt, contentSize: CGSize) {
        self.width = width
        self.height = height
        self.format = pixelFormat
        self.maxS = Float(contentSize.width) / Float(width)
        self.maxT = Float(contentSize.height) / Float(height)
        super.init()
        if pixelFormat == .RGBA8 || nextPower2(width) == width && nextPower2(height) == height {
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 4)
        } else {
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        }
        
        // create texture object
        glGenTextures(1, &_glID);
        // bind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), _glID);
        // set minifying and magnification function
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR);
        // set wrap parameter
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        // set pixel data to texture object
        if !pixelFormat.compressed {
            var formats = pixelFormat.formats
            glTexImage2D(
                GLenum(GL_TEXTURE_2D),
                0,
                formats.internalFormat,
                GLsizei(width),
                GLsizei(height),
                0,
                formats.format,
                formats.type,
                data)
        } else {
            var formats = pixelFormat.compressedFormats
            glCompressedTexImage2D(
                GLenum(GL_TEXTURE_2D),
                0,
                formats.internalFormat,
                GLsizei(width),
                GLsizei(height),
                0,
                GLsizei((width / 4 * height / 4) * formats.imageSizeScale),
                data)
        }
        // unbind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    deinit {
        self.release()
    }
    
    public func refresh(data: UnsafePointer<Void>, width: UInt, height: UInt, offsetX: Int, offsetY: Int) {
        if self.format == .RGBA8 || nextPower2(width) == width && nextPower2(height) == height {
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 4)
        } else {
            glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
        }
        // bind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), _glID)
        // set pixel data to texture object
        if !self.format.compressed {
            var formats = self.format.formats
            glTexSubImage2D(
                GLenum(GL_TEXTURE_2D),
                0,
                GLint(offsetX),
                GLint(offsetY),
                GLsizei(width),
                GLsizei(height),
                formats.format,
                formats.type,
                data)
        } else {
            var formats = self.format.compressedFormats
            glCompressedTexSubImage2D(
                GLenum(GL_TEXTURE_2D),
                0,
                GLint(offsetX),
                GLint(offsetY),
                GLsizei(width),
                GLsizei(height),
                formats.internalFormat,
                GLsizei((width / 4 * height / 4) * formats.imageSizeScale),
                data)
        }
        // unbind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    public func setAntiAlias(antiAlias: Bool) {
        // bind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), _glID)
        if antiAlias {
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST_MIPMAP_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        } else {
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        }
        // unbind texture object
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    public func generateMipmap() {
        glGenerateMipmap(_glID)
    }
    
    public func release() {
        if _glID != 0 {
            glDeleteTextures(1, &_glID)
            _glID = 0
        }
    }
}

// extension for CGImage
public extension AQGLTexture2D {
    
    public convenience init(image: CGImageRef, orientation: UIImageOrientation, var pixelFormat: AQGLTexture2DPixelFormat) {
        let isPOT = !AQGLSupportInfo.sharedInfo.supportNPOT
        let info = CGImageGetAlphaInfo(image)
        let hasAlpha = ((info == .PremultipliedLast) || (info == .PremultipliedFirst) || (info == .Last) || (info == .First) ? true : false);
        
        // infer pixel format if pixel format is automatic
        if pixelFormat == .Automatic {
            if let colorSpace = CGImageGetColorSpace(image) {
                // monochrome color space
                if CGColorSpaceGetModel(colorSpace).value == kCGColorSpaceModelMonochrome.value {
                    pixelFormat = hasAlpha ? .LA88 : .L8
                    #if DEBUG
                        if CGImageGetBitsPerComponent(image) != 8 && CGImageGetBitsPerPixel(image) != 16 {
                            AQLog.log("Unoptinal image pixel format for image")
                        }
                    #endif
                    // RGB(A) color space
                } else {
                    if CGImageGetBitsPerPixel(image) == 16 {
                        pixelFormat = hasAlpha ? .RGBA5551 : .RGB565
                    } else {
                        pixelFormat = hasAlpha ? .RGBA8 : .RGB8
                        #if DEBUG
                            if CGImageGetBitsPerComponent(image) != 8 && CGImageGetBitsPerPixel(image) != 24 {
                                AQLog.log("Unoptinal image pixel format for image");
                            }
                        #endif
                    }
                }
            } else {
                // no colorspace means a mask image
                pixelFormat = .A8;
                #if DEBUG
                    if CGImageGetBitsPerComponent(image) != 8 && CGImageGetBitsPerPixel(image) != 8 {
                        AQLog.log("Unoptinal image pixel format for image");
                    }
                #endif
            }
        }
        var imageSize = CGSizeMake(CGFloat(CGImageGetWidth(image)), CGFloat(CGImageGetHeight(image)))
        // handle the orientation
        var transform: CGAffineTransform
        switch orientation {
        case .Up: // EXIF = 1
            transform = CGAffineTransformIdentity
        case .UpMirrored: // EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
        case .Down: // EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        case .DownMirrored: // EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height)
            transform = CGAffineTransformScale(transform, 1.0, -1.0)
        case .LeftMirrored: // EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width)
            transform = CGAffineTransformScale(transform, -1.0, 1.0)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
        case .Left: // EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width)
            transform = CGAffineTransformRotate(transform, 3.0 * CGFloat(M_PI) / 2.0)
        case .RightMirrored: // EXIF = 7
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
        case .Right: // EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI) / 2.0)
        default:
            transform = CGAffineTransformIdentity
            AQLog.log("Invalid image orientation")
        }
        if orientation == .LeftMirrored || orientation == .Left ||
            orientation == .RightMirrored || orientation == .Right {
                imageSize = CGSizeMake(imageSize.height, imageSize.width)
        }
        
        var width = UInt(imageSize.width)
        var height = UInt(imageSize.height)
        if isPOT {
            width = nextPower2(width)
            height = nextPower2(height)
        }
        
        // test if image size is smaller than supported maximum texture size
        let maxSize = AQGLSupportInfo.sharedInfo.maxTextureSize
        if GLint(width) > maxSize || GLint(height) > maxSize {
            AQLog.log("Image at \(width) x \(height) pixels is too big to fit in texture")
            if !isPOT {
                var scale: CGFloat
                if width > height {
                    scale = CGFloat(width) / CGFloat(maxSize)
                    height = UInt(CGFloat(width * height) / CGFloat(maxSize))
                    width = UInt(maxSize)
                } else {
                    scale = CGFloat(height) / CGFloat(maxSize)
                    width = UInt(CGFloat(width * height) / CGFloat(maxSize))
                    height = UInt(maxSize);
                }
                imageSize.width = CGFloat(width);
                imageSize.height = CGFloat(height);
                transform = CGAffineTransformScale(transform, scale, scale);
            } else {
                while GLint(width) > maxSize || GLint(height) > maxSize {
                    width /= 2;
                    height /= 2;
                    transform = CGAffineTransformScale(transform, 0.5, 0.5);
                    imageSize.width *= 0.5;
                    imageSize.height *= 0.5;
                }
            }
        }
        
        var context: CGContext!
        var colorSpace: CGColorSpaceRef
        var data: UnsafeMutablePointer<Void>
        // create bitmap context
        switch pixelFormat {
        case .RGBA8, .RGBA4:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            data = malloc(width * height * 4)
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, .ByteOrder32Big)
        case .RGBA5551:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            data = malloc(width * height * 2)
            context = CGBitmapContextCreate(data, width, height, 5, 2 * width, colorSpace, .ByteOrder16Little)
        case .RGB8, .RGB565:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            data = malloc(width * height * 4)
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, .ByteOrder32Big)
        case .L8:
            colorSpace = CGColorSpaceCreateDeviceGray()
            data = malloc(width * height)
            context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, .ByteOrderDefault)
        case .A8:
            data = malloc(width * height)
            context = CGBitmapContextCreate(data, width, height, 8, width, nil, .ByteOrderDefault)
        case .LA88:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(width * height * 4)
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, .ByteOrder32Big)
        default:
            data = nil
        }
        
        if context == nil {
            AQLog.log("Failed creating CGBitmapContext")
            self.init(data: data, pixelFormat: pixelFormat, width: 0, height: 0, contentSize: CGSize(width: 0,height: 0))
            free(data)
            return
        }
        
        CGContextClearRect(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)))
        CGContextTranslateCTM(context, 0, CGFloat(height) - imageSize.height)
        CGContextConcatCTM(context, transform)
        CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(CGImageGetWidth(image)), CGFloat(CGImageGetHeight(image))), image)
        
        var tempData: UnsafeMutablePointer<Void>
        var inPixel8: UnsafeMutablePointer<CUnsignedChar>
        var inPixel32: UnsafeMutablePointer<CUnsignedInt>
        var outPixel8: UnsafeMutablePointer<CUnsignedChar>
        var outPixel16: UnsafeMutablePointer<CUnsignedShort>
        
        switch pixelFormat {
        case .RGBA5551:
            aq_convert_RGB565_RGBA5551(data, data, CUnsignedInt(width), CUnsignedInt(height))
            AQLog.log("Falling off fast-path converting pixel data from ARGB1555 to RGBA5551")
        case .RGB8:
            tempData = malloc(width * height * 3)
            aq_convert_RGBA8_RGB8(data, tempData, CUnsignedInt(width), CUnsignedInt(width))
            free(data)
            data = tempData
            AQLog.log("Falling off fast-path converting pixel data from RGBA8888 to RGB888")
        case .RGB565:
            tempData = malloc(width * height * 2)
            aq_convert_RGBA8_RGB565(data, tempData, CUnsignedInt(width), CUnsignedInt(height))
            free(data)
            data = tempData
            AQLog.log("Falling off fast-path converting pixel data from RGBA8888 to RGB565")
        case .RGBA4:
            tempData = malloc(width * height * 2)
            aq_convert_RGBA8_RGBA4(data, tempData, CUnsignedInt(width), CUnsignedInt(height))
            free(data)
            data = tempData
            AQLog.log("Falling off fast-path converting pixel data from RGBA8888 to RGBA4444")
        case .LA88:
            tempData = malloc(width * height * 2)
            aq_convert_RGBA8_LA88(data, tempData, CUnsignedInt(width), CUnsignedInt(height))
            free(data)
            data = tempData
            AQLog.log("Falling off fast-path converting pixel data from RGBA8888 to LA88")
        default:
            break
        }
        
        self.init(data: data, pixelFormat: pixelFormat, width: 0, height: 0, contentSize: CGSize(width: 0,height: 0))
        
        free(data)
    }
}


