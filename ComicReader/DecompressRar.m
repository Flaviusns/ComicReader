//
//  DecompressRar.m
//  ComicReader
//
//  Created by Flavius Stan on 18/04/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecompressRar.h"
@import UnrarKit;



@implementation DecompressRar : NSObject

- (BOOL) extractFile:(NSString *) path withSecond:(NSString *) extractPath {
    
    /* local variable declaration */
    
    NSError *archiveError = nil;
    URKArchive *archive = [[URKArchive alloc] initWithPath:path error:&archiveError];
    NSError *error = nil;
    
    BOOL extractFilesSuccessful = [archive extractFilesTo:extractPath overwrite:NO error:&error];
    
    NSLog(@"%d",extractFilesSuccessful);
    
    return extractFilesSuccessful;
}

//- (NSMutableArray<NSData *> *)
-(void) extractFileToMemory:(NSString *) path {
    NSError *archiveError = nil;
    URKArchive *archive = [[URKArchive alloc] initWithPath:path error:&archiveError];
    NSError *error = nil;
    
    //NSData *extractedData = [archive extractDataFromFile: path
                                                   //error:&error];
    NSArray<NSString*> *filesInArchive = [archive listFilenames:&error];
    for (NSString *name in filesInArchive) {
        NSLog(@"Archived file: %@", name);
    }
}

@end
