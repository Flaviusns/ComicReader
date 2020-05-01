//
//  DecompressRar.h
//  ComicReader
//
//  Created by Flavius Stan on 18/04/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

#ifndef DecompressRar_h
#define DecompressRar_h

#import <Foundation/Foundation.h>

@interface DecompressRar : NSObject


- (BOOL) extractFile:(NSString *) path withSecond:(NSString *) extractPath;

@end

#endif /* DecompressRar_h */
