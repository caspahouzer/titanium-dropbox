//
//  DBMetadata.m
//  DropboxSDK
//
//  Created by Brian Smith on 5/3/10.
//  Copyright 2010 Dropbox, Inc. All rights reserved.
//

#import "DBMetadata.h"
#import "TiBase.h"

@implementation DBMetadata

+ (NSDateFormatter*)dateFormatter {
	NSMutableDictionary* dictionary = [[NSThread currentThread] threadDictionary];
	static NSString* dateFormatterKey = @"DBMetadataDateFormatter";
	
    NSDateFormatter* dateFormatter = [dictionary objectForKey:dateFormatterKey];
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter new] autorelease];
        // Must set locale to ensure consistent parsing:
        // http://developer.apple.com/iphone/library/qa/qa2010/qa1480.html
		dateFormatter.locale = 
			[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
		dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
        [dictionary setObject:dateFormatter forKey:dateFormatterKey];
    }
    return dateFormatter;
}

- (id)initWithDictionary:(NSDictionary*)dict {
    if ((self = [super init])) {
        thumbnailExists = [[dict objectForKey:@"thumb_exists"] boolValue];
        totalBytes = [[dict objectForKey:@"bytes"] longLongValue];

        if ([dict objectForKey:@"modified"]) {
            lastModifiedDate = 
				[[[DBMetadata dateFormatter] dateFromString:[dict objectForKey:@"modified"]] retain];
        }

        path = [[dict objectForKey:@"path"] retain];
        isDirectory = [[dict objectForKey:@"is_dir"] boolValue];
        
        if ([dict objectForKey:@"contents"]) {
            NSArray* subfileDicts = [dict objectForKey:@"contents"];
            NSMutableArray* mutableContents = 
                [[NSMutableArray alloc] initWithCapacity:[subfileDicts count]];
            for (NSDictionary* subfileDict in subfileDicts) {
                DBMetadata* subfile = [[DBMetadata alloc] initWithDictionary:subfileDict];
                [mutableContents addObject:subfile];
                [subfile release];
            }
            contents = mutableContents;
        }
        
        hash = [[dict objectForKey:@"hash"] retain];
        humanReadableSize = [[dict objectForKey:@"size"] retain];
        root = [[dict objectForKey:@"root"] retain];
        icon = [[dict objectForKey:@"icon"] retain];
        revision = [[dict objectForKey:@"revision"] longLongValue];
        isDeleted = [[dict objectForKey:@"is_deleted"] boolValue];
    }
    return self;
}

-(void)dumpToDictionary:(NSMutableDictionary *)dictionary {
  [dictionary setObject:NUMBOOL(self.thumbnailExists) forKey:@"thumbnailExists"];
  [dictionary setObject:NUMLONGLONG(self.totalBytes) forKey:@"totalBytes"];
  [dictionary setObject:self.lastModifiedDate forKey:@"lastModifiedDate"];
  [dictionary setObject:self.path forKey:@"path"];
  [dictionary setObject:NUMBOOL(self.isDirectory) forKey:@"isDirectory"];
  [dictionary setObject:NULL_IF_NIL(self.hash) forKey:@"hash"];
  [dictionary setObject:self.humanReadableSize forKey:@"humanReadableSize"];
  [dictionary setObject:NULL_IF_NIL(self.root) forKey:@"root"];
  [dictionary setObject:NULL_IF_NIL(self.icon) forKey:@"icon"];
  [dictionary setObject:NUMLONGLONG(self.revision) forKey:@"revision"];
  [dictionary setObject:NUMBOOL(self.isDeleted) forKey:@"isDeleted"];
  
  NSMutableArray *c = [NSMutableArray array];
  
  for(DBMetadata *item in self.contents) {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [item dumpToDictionary:d];
    [c addObject:d];
  }
  
  [dictionary setObject:c forKey:@"contents"];
}

- (void)dealloc {
    [lastModifiedDate release];
    [path release];
    [contents release];
    [hash release];
    [humanReadableSize release];
    [root release];
    [icon release];
    [super dealloc];
}

@synthesize thumbnailExists;
@synthesize totalBytes;
@synthesize lastModifiedDate;
@synthesize path;
@synthesize isDirectory;
@synthesize contents;
@synthesize hash;
@synthesize humanReadableSize;
@synthesize root;
@synthesize icon;
@synthesize revision;
@synthesize isDeleted;


#pragma mark NSCoding methods

- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super init])) {
        thumbnailExists = [coder decodeBoolForKey:@"thumbnailExists"];
        totalBytes = [coder decodeInt64ForKey:@"totalBytes"];
        lastModifiedDate = [[coder decodeObjectForKey:@"lastModifiedDate"] retain];
        path = [[coder decodeObjectForKey:@"path"] retain];
        isDirectory = [coder decodeBoolForKey:@"isDirectory"];
        contents = [[coder decodeObjectForKey:@"contents"] retain];
        hash = [[coder decodeObjectForKey:@"hash"] retain];
        humanReadableSize = [[coder decodeObjectForKey:@"humanReadableSize"] retain];
        root = [[coder decodeObjectForKey:@"root"] retain];
        icon = [[coder decodeObjectForKey:@"icon"] retain];
        revision = [coder decodeInt64ForKey:@"revision"];
        isDeleted = [coder decodeBoolForKey:@"isDeleted"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeBool:thumbnailExists forKey:@"thumbnailExists"];
    [coder encodeInt64:totalBytes forKey:@"totalBytes"];
    [coder encodeObject:lastModifiedDate forKey:@"lastModifiedDate"];
    [coder encodeObject:path forKey:@"path"];
    [coder encodeBool:isDirectory forKey:@"isDirectory"];
    [coder encodeObject:contents forKey:@"contents"];
    [coder encodeObject:hash forKey:@"hash"];
    [coder encodeObject:humanReadableSize forKey:@"humanReadableSize"];
    [coder encodeObject:root forKey:@"root"];
    [coder encodeObject:icon forKey:@"icon"];
    [coder encodeInt64:revision forKey:@"revision"];
    [coder encodeBool:isDeleted forKey:@"isDeleted"];
}


@end
