//
//  sprintVC.m
//  sprintTimer
//
//  Created by Sten Kaiser on 2011-03-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Motion.h"
#import <Accelerate/Accelerate.h>

@implementation Motion


-(float)detect:(CVImageBufferRef) imageBuffer{
//         double testTime = CACurrentMediaTime();
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    size_t bytesPerRowY = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
    size_t  bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,1);
    size_t planeSizeY = bytesPerRowY*CVPixelBufferGetHeightOfPlane(imageBuffer,0);
    size_t  planeSizeUV = bytesPerRowUV*CVPixelBufferGetHeightOfPlane(imageBuffer,1);
    unsigned char *baseAddressY = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    unsigned char *baseAddressUV = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    
    static float HistY[12][64];
    static float HistUV[12][64];
    static float tempHistY[12][64];
    static float tempHistUV[12][64];
    
    BOOL videoHD = false;
    if (bytesPerRowY > 1000 ) videoHD = true;
    float scaleHD = 1.0+0.5*videoHD;
    int bSizeY = scaleHD*scaleHD*(1280*720-10);
    int bSizeUV = scaleHD*scaleHD*(1280*360-10);
    
    if(planeSizeY>bSizeY && planeSizeUV>bSizeUV) {
        float nyHistY[12][64];
        float nyHistUV[12][64];
        
        vImagePixelCount histogramY[256];
        vImagePixelCount histogramUV[256];
        
        int col = 3;
        int row = 4;
        int zoneW = scaleHD*72;
        int zoneH = scaleHD*60;
        
        int zoneX0 = scaleHD*600; //top x
        int zoneY0 = scaleHD*200; // top y
        float antZ = zoneH*zoneW;

        int langd = 64;
        float multY[langd], multUV[langd];
        float sqtY[langd], sqtUV[langd];
        float histFloatY[256];
        float histFloatUV[256];
        float BClow = 1.0;
        
        vImage_Error err;
        vImage_Buffer vBuffY;
        vBuffY.height = zoneH;
        vBuffY.width = zoneW;
        vBuffY.rowBytes = bytesPerRowY;

        vImage_Buffer vBuffUV;
        vBuffUV.height = zoneH/2;
        vBuffUV.width = zoneW;
        vBuffUV.rowBytes = bytesPerRowUV;
        
        for (int i=0;i<col;i++){
            for (int j=0;j<row;j++){
                int z = i*row + j;
                long startposY = (zoneY0+j*zoneH)*bytesPerRowY+zoneX0+i*zoneW;
                long startposUV = (zoneY0+j*zoneH)*bytesPerRowUV/2+zoneX0+i*zoneW;
     
                vBuffY.data = baseAddressY+startposY;
                err = vImageHistogramCalculation_Planar8(&vBuffY,histogramY, 0);
                
                vBuffUV.data = baseAddressUV+startposUV;
                err = vImageHistogramCalculation_Planar8(&vBuffUV,histogramUV, 0);
                
                if (err != kvImageNoError) NSLog(@"histogram %ld", err);
                
                vDSP_vfltu32((const unsigned int*)histogramY,2,histFloatY,1,256);
                vDSP_vfltu32((const unsigned int*)histogramUV,2,histFloatUV,1,256);

                vDSP_vadd(histFloatY,4,histFloatY+1,4,nyHistY[z],1,64);
                vDSP_vadd(histFloatUV,4,histFloatUV+1,4,nyHistUV[z],1,64);
                
                vDSP_vadd(histFloatY+2,4,nyHistY[z],1,nyHistY[z],1,64);
                vDSP_vadd(histFloatUV+2,4,nyHistUV[z],1,nyHistUV[z],1,64);
                
                vDSP_vadd(histFloatY+3,4,nyHistY[z],1,nyHistY[z],1,64);
                vDSP_vadd(histFloatUV+3,4,nyHistUV[z],1,nyHistUV[z],1,64);
                
                vDSP_vmul(nyHistY[z],1,HistY[z],1,multY,1,langd);
                vDSP_vmul(nyHistUV[z],1,HistUV[z],1,multUV,1,langd);
                
                vvsqrtf(sqtY,multY,&langd);
                vvsqrtf(sqtUV,multUV,&langd);
                
                float sumY, sumUV;
                
                vDSP_sve(sqtY,1,&sumY,langd);
                vDSP_sve(sqtUV,1,&sumUV,langd);
                
                float BCm = 2*sumY*sumUV/(antZ*antZ);
                if(BCm<BClow) BClow = BCm;
            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

        memcpy(HistY, tempHistY, sizeof(int)*64*12);
        memcpy(HistUV, tempHistUV, sizeof(int)*64*12);
        memcpy(tempHistY, nyHistY, sizeof(int)*64*12);
        memcpy(tempHistUV, nyHistUV, sizeof(int)*64*12);
//        NSLog(@"BClow %.3f ", BClow);
//        NSLog(@"testtime more %.3f ", CACurrentMediaTime()-testTime);
        return BClow;
        
    } else {
        return  1.0;
    }
}



//- (void)tand:(float)BClow{
//    self.detectionZone.highlighted = YES;
//    self.sensLabel.text = [NSString stringWithFormat:@"%@\n%@",[self deciMal:BClow deci:2], [self deciMal:sens deci:2]];
//    [self performSelector:@selector(slack) withObject:nil afterDelay:0.7];
//}
//
//- (void)slack{
//    self.detectionZone.highlighted = NO;
//    self.sensLabel.text = [NSString stringWithFormat:@"%@",[self deciMal:sens deci:2]];
//}


@end
