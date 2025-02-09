//
//  SLSLogData.m
//  
//
//  Created by gordon on 2023/2/2.
//

#import "SLSLogData.h"
#import "../SLSTimeUtils.h"

@implementation SLSLogData
+ (SLSLogDataBuilder *) builder {
    return [SLSLogDataBuilder builder];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scope = [SLSLogScope getDefault];
        _logRecords = [NSMutableArray array];
    }
    return self;
}

- (SLSLogData *) addRecord: (SLSRecord *) record {
    if (nil == record) {
        return self;
    }
    
    NSMutableArray *array = (NSMutableArray *)_logRecords;
    [array addObject:record];
    return self;
}

- (NSDictionary *) toJson {
    return @{
        @"resource": nil != _resource ? [_resource toDictionary] : @{},
        @"scopeLogs": @[
            @{
                @"scope": [_scope toJson],
                @"logRecords": [SLSRecord toArray:_logRecords]
            }
        ]
    };
}
@end

@implementation SLSLogDataBuilder

+ (SLSLogDataBuilder *) builder {
    return [[SLSLogDataBuilder alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _epochNanos = -1;
        _level = SLS_LOGS_ERROR;
    }
    return self;
}

- (SLSLogDataBuilder *) setResource: (SLSResource *) resource {
    _resource = resource;
    return self;
}
- (SLSLogDataBuilder *) setLogsLevel: (SLSLogsLevel) level {
    _level = level;
    return self;
}
- (SLSLogDataBuilder *) setSeverityText: (NSString *) severityText {
    _severityText = severityText;
    return self;
}
- (SLSLogDataBuilder *) setScope: (SLSLogScope *) scope {
    _scope = scope;
    return self;
}
- (SLSLogDataBuilder *) setEpochNanos: (NSInteger *) epochNanos {
    _epochNanos = epochNanos;
    return self;
}
- (SLSLogDataBuilder *) setTraceId: (NSString *) traceId {
    _traceId = traceId;
    return self;
}
- (SLSLogDataBuilder *) setSpanId: (NSString *) spanId {
    _spanId = spanId;
    return self;
}
- (SLSLogDataBuilder *) setLogContent: (NSString *) content {
    _logContent = content;
    return self;
}
- (SLSLogDataBuilder *) setAttribute: (NSArray<SLSAttribute *> *) attributes {
    _attributes = attributes;
    return self;
}

- (SLSLogData *) build {
    SLSLogData *data = [[SLSLogData alloc] init];
    data.resource = _resource;
    data.scope = nil != _scope ? _scope : [SLSLogScope getDefault];
    
    SLSRecord *record = [SLSRecord record];
    record.timeUnixNano = -1 != _epochNanos ? _epochNanos : [SLSTimeUtils now];
    record.severityNumber = [self getSeverityNumber:_level];
    record.severityText = _severityText.length > 0 ? _severityText : [self getSeverityText:_level];
    record.body.stringValue = _logContent;
    if (nil != _attributes) {
        [record addAttribute:_attributes];
    }
    record.traceId = _traceId;
    record.spanId = _spanId;
    
    [data addRecord:record];
    return data;
}

- (NSString *) getSeverityNumber: (SLSLogsLevel) level {
    switch (level) {
        case SLS_LOGS_UNDEFINED_SEVERITY_NUMBER: return @"UNDEFINED_SEVERITY_NUMBER";
        case SLS_LOGS_TRACE: return @"SEVERITY_NUMBER_TRACE";
        case SLS_LOGS_DEBUG: return @"SEVERITY_NUMBER_DEBUG";
        case SLS_LOGS_INFO: return @"SEVERITY_NUMBER_INFO";
        case SLS_LOGS_WARN: return @"SEVERITY_NUMBER_WARN";
        case SLS_LOGS_ERROR: return @"SEVERITY_NUMBER_ERROR";
        case SLS_LOGS_FATAL: return @"SEVERITY_NUMBER_FATAL";
        default:  return @"UNDEFINED_SEVERITY_NUMBER";
    }
}

- (NSString *) getSeverityText: (SLSLogsLevel) level {
    switch (level) {
        case SLS_LOGS_UNDEFINED_SEVERITY_NUMBER: return @"UNDEFINED_SEVERITY_NUMBER";
        case SLS_LOGS_TRACE: return @"TRACE";
        case SLS_LOGS_DEBUG: return @"DEBUG";
        case SLS_LOGS_INFO: return @"INFO";
        case SLS_LOGS_WARN: return @"WARN";
        case SLS_LOGS_ERROR: return @"ERROR";
        case SLS_LOGS_FATAL: return @"FATAL";
        default:  return @"UNDEFINED_SEVERITY_NUMBER";
    }
}

@end
