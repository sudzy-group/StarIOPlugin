/*
 *   Licensed to the Apache Software Foundation (ASF) under one
 *   or more contributor license agreements.  See the NOTICE file
 *   distributed with this work for additional information
 *   regarding copyright ownership.  The ASF licenses this file
 *   to you under the Apache License, Version 2.0 (the
 *   "License"); you may not use this file except in compliance
 *   with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing,
 *   software distributed under the License is distributed on an
 *   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *   KIND, either express or implied.  See the License for the
 *   specific language governing permissions and limitations
 *   under the License.
 *
 *      CDVPlugin
 *      CDVPlugin Template Created 05/09/2015.
 *      Copyright 2013 @RandyMcMillan
 *
 *     Created by Younes on 05/09/2015.
 *     Copyright __MyCompanyName__ 2015. All rights reserved.
 */

#import <Cordova/CDVAvailability.h>
#import <Cordova/CDVViewController.h>

#import "StarIOPlugin.h"
#import "StarIOPlugin_JS.h"
#import "StarIOPlugin_Communication.h"
#import "RasterDocument.h"
#import "MiniPrinterFunctions.h"
#import "StarBitmap.h"

@implementation StarIOPlugin

static NSString *dataCallbackId = nil;

- (void)init:(CDVInvokedUrlCommand *)command
{
    NSLog(@"init called from %@!", [self class]);
    
    if (self.hasPendingOperation) {
        //        [self.commandDelegate runInBackground:^{NSLog(@"BackGround Thread sample code!");}];
        NSLog(@"%@.hasPendingOperation = YES", [self class]);
    } else {
        //        [self.commandDelegate runInBackground:^{NSLog(@"BackGround Thread sample code!");}];
        NSLog(@"%@.hasPendingOperation = NO", [self class]);
    }
    
    NSString    *systemVersion      = [[UIDevice currentDevice] systemVersion];
    BOOL        isLessThaniOS4      = ([systemVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedAscending);
    BOOL        isGreaterThaniOS4   = ([systemVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedDescending);
    BOOL        isLessThaniOS5      = ([systemVersion compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending);
    BOOL        isGreaterThaniOS5   = ([systemVersion compare:@"5.0" options:NSNumericSearch] == NSOrderedDescending);
    BOOL        isLessThaniOS6      = ([systemVersion compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending);
    BOOL        isEqualToiOS6       = ([systemVersion compare:@"6.0" options:NSNumericSearch] == NSOrderedSame);
    BOOL        isGreaterThaniOS6   = ([systemVersion compare:@"6.0" options:NSNumericSearch] == NSOrderedDescending);
    
    if (isLessThaniOS4 && isLessThaniOS5) {}
    
    if (isGreaterThaniOS4 && isLessThaniOS5) {}
    
    if (isGreaterThaniOS5 && isLessThaniOS6) {}
    
    if (isEqualToiOS6) {
        NSLog(@"isEqualToiOS6");
    }
    
    if (isGreaterThaniOS6) {
        NSLog(@"isGreaterThaniOS6");
    }
    
    NSString    *callbackId     = [command.arguments objectAtIndex:0];
    NSString    *objectAtIndex0 = [command.arguments objectAtIndex:0];
    
    CDVViewController   *mvcCDVPlugin = (CDVViewController *)[super viewController];
    CDVPluginResult     *result;
    
    // [self.commandDelegate runInBackground:^{NSLog(@"BackGround Thread sample code!");}];
    
    _starIoExtManager = nil;
    
    if ([objectAtIndex0 isEqualToString:@"success"]) {
        NSString *jsString = kCDVPluginINIT;
        [mvcCDVPlugin.webViewEngine evaluateJavaScript:jsString completionHandler:^(id id, NSError * error) {
            NSLog(@"Initialized StarIOPlugin and notified webViewEngine");
        }];
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Success! const kCDVPluginINIT was evaluated by webview!"];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    } else {NSLog(@"[command.arguments objectAtIndex:0] = %@", [command.arguments objectAtIndex:0]); }
}



- (void)checkStatus:(CDVInvokedUrlCommand *)command {
    NSLog(@"Checking status");
    [self.commandDelegate runInBackground:^{
        NSString *portName = nil;
        CDVPluginResult *result = nil;
        StarPrinterStatus_2 status;
        SMPort *port = nil;
        
        if (command.arguments.count > 0) {
            portName = [command.arguments objectAtIndex:0];
        }
        @try {
            //TODO - Run in background
            if (_starIoExtManager == nil || _starIoExtManager.port == nil) {
                port = [SMPort getPort:portName :@"" :10000];
            } else {
                port = [_starIoExtManager port];
            }
            //TODO - wait till connected
            [port getParsedStatus:&status :2];
            NSDictionary *statusDictionary = [self portStatusToDictionary:status];
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:statusDictionary];
        }
        @catch (PortException *exception) {
            NSLog(@"Port exception");
        }
        @finally {
            if (port != nil) {
                [SMPort releasePort:port];
            }
        }
        
        NSLog(@"Sending status result");
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)portDiscovery:(CDVInvokedUrlCommand *)command {
    NSLog(@"Finding ports");
    [self.commandDelegate runInBackground:^{
        NSString *portType = @"All";
        
        if (command.arguments.count > 0) {
            portType = [command.arguments objectAtIndex:0];
        }
        
        NSMutableArray *info = [[NSMutableArray alloc] init];
        
        //TODO - run in background
        if ([portType isEqualToString:@"All"]) {
            NSArray *allPortInfoArray = [SMPort searchPrinter];
            for (PortInfo *p in allPortInfoArray) {
                [info addObject:[self portInfoToDictionary:p]];
            }
        }
        else {
            if ([portType isEqualToString:@"Bluetooth"]) {
                NSArray *btPortInfoArray = [SMPort searchPrinter:@"BT:"];
                for (PortInfo *p in btPortInfoArray) {
                    [info addObject:[self portInfoToDictionary:p]];
                }
            }
            
            if ([portType isEqualToString:@"BluetoothLE"]) {
                NSArray *btPortInfoArray = [SMPort searchPrinter:@"BLE:"];
                for (PortInfo *p in btPortInfoArray) {
                    [info addObject:[self portInfoToDictionary:p]];
                }
            }
            
            if ([portType isEqualToString:@"LAN"]) {
                NSArray *lanPortInfoArray = [SMPort searchPrinter:@"TCP:"];
                for (PortInfo *p in lanPortInfoArray) {
                    [info addObject:[self portInfoToDictionary:p]];
                }
            }
            
            if ([portType isEqualToString:@"USB"]) {
                NSArray *usbPortInfoArray = [SMPort searchPrinter:@"USB:"];
                for (PortInfo *p in usbPortInfoArray) {
                    [info addObject:[self portInfoToDictionary:p]];
                }
            }
        }
        
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:info];
        
        NSLog(@"Sending ports result");
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)connect:(CDVInvokedUrlCommand *)command {
    NSString *portName = nil;
    
    if (command.arguments.count > 0) {
        portName = [command.arguments objectAtIndex:0];
    }
    
    if (_starIoExtManager == nil) {
        _starIoExtManager = [[StarIoExtManager alloc] initWithType:StarIoExtManagerTypeWithBarcodeReader
                                                          portName:portName
                                                      portSettings:@""
                                                   ioTimeoutMillis:10000];
        
        _starIoExtManager.delegate = self;
    }
    
    if (_starIoExtManager.port != nil) {
        [_starIoExtManager disconnect];
    }
    
    dataCallbackId = command.callbackId;
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[_starIoExtManager connect]];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
}





- (void)printImage:(CDVInvokedUrlCommand *)command {
    NSLog(@"printing image");
    [self.commandDelegate runInBackground:^{
        NSString *portName = nil;
        NSString *base64 = nil;
        int maxWidth = 0;
        SMPort *port = nil;
        BOOL releasePort = false;
        
        if (command.arguments.count > 0) {
            portName = [command.arguments objectAtIndex:0];
            base64 = [command.arguments objectAtIndex:1];
            maxWidth = 600;
        }
        
        if (_starIoExtManager == nil || _starIoExtManager.port == nil) {
            port = [SMPort getPort:portName :@"" :10000];
            releasePort = true;
        } else {
            port = [_starIoExtManager port];
        }
        
        NSData* imageData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
        
        UIImage* image = [UIImage imageWithData:imageData];
        
        RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium endOfPageBehaviour:RasPageEndMode_FeedAndFullCut endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut topMargin:RasTopMargin_Standard pageLength:0 leftMargin:0 rightMargin:0];
        
        StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:image :maxWidth :false];
        
        NSMutableData *commandsToPrint = [[NSMutableData alloc] init];
        
        NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
        
        [commandsToPrint appendData:shortcommand];
        
        shortcommand = [starbitmap getImageDataForPrinting:YES]; // try NO
        [commandsToPrint appendData:shortcommand];
        
        shortcommand = [rasterDoc EndDocumentCommandData];
        [commandsToPrint appendData:shortcommand];
        
        // [starbitmap release];
        // [rasterDoc release];
        // [image release];
        //        [imageData release];
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock lock];
        }
        
        BOOL printResult = false;
        
        @try {
            printResult = [StarIOPlugin_Communication sendCommands:commandsToPrint port:port];
        }
        @finally {
            if (port != nil && releasePort) {
                [SMPort releasePort:port];
            }
        }
        
        // [commandsToPrint release];
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock unlock];
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:printResult];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}







- (void)printReceipt:(CDVInvokedUrlCommand *)command {
    NSLog(@"printing receipt");
    [self.commandDelegate runInBackground:^{
        NSMutableData *commands = [NSMutableData data];
        NSString *portName = nil;
        NSString *content = nil;
        SMPort *port = nil;
        BOOL releasePort = false;
        
        if (command.arguments.count > 0) {
            portName = [command.arguments objectAtIndex:0];
            content = [command.arguments objectAtIndex:1];
        }
        
        if (_starIoExtManager == nil || _starIoExtManager.port == nil) {
            port = [SMPort getPort:portName :@"" :10000];
            releasePort = true;
        } else {
            NSLog(@"starIoExtManager != nil");
            port = [_starIoExtManager port];
        }
        
        [commands appendData:[content dataUsingEncoding:NSASCIIStringEncoding]];
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock lock];
        }
        
        BOOL printResult = false;
        
        @try {
            printResult = [StarIOPlugin_Communication sendCommands:commands port:port];
        }
        @finally {
            if (port != nil && releasePort) {
                [SMPort releasePort:port];
            }
        }
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock unlock];
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:printResult];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}


- (void)printMobile: (CDVInvokedUrlCommand*)command
{
    NSString *name = nil;
    NSString *address = nil;
    NSString *phone = nil;
    NSString *date = nil;
    if (command.arguments.count > 0) {
        name = [command.arguments objectAtIndex:0];
        address = [command.arguments objectAtIndex:1];
        phone =[command.arguments objectAtIndex:2];
        date = [command.arguments objectAtIndex:3];
    }
       CDVPluginResult* pluginResult = nil;
    
    NSMutableString* message = [NSMutableString stringWithString:@""];
    
    
    [MiniPrinterFunctions PrintFullReceiptWithPortname:@"BT:PRNT Star"
                                                  name: name
                                               address:address
                                                 phone: phone
                                                  date: date
                                          portSettings:@"Portable;escpos"
                                            paperWidth:2
                                          errorMessage:message];
    NSUInteger length = [message length];
    
    if (length == 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)openExternalCashDrawer:(CDVInvokedUrlCommand *)command {
    NSLog(@"opening external cash drawer");
    
    [self.commandDelegate runInBackground:^{
        NSString *portName = nil;
        SMPort *port = nil;
        BOOL releasePort = false;
        
        if (command.arguments.count > 0) {
            portName = [command.arguments objectAtIndex:0];
        }
        
        if (_starIoExtManager == nil || _starIoExtManager.port == nil) {
            port = [SMPort getPort:portName :@"" :10000];
            releasePort = true;
        } else {
            port = [_starIoExtManager port];
        }
        
        unsigned char openCashDrawerCommand = 0x1a;
        
        NSData *commandData = [NSData dataWithBytes:&openCashDrawerCommand length:1];
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock lock];
        }
        
        BOOL printResult;
        
        @try {
            printResult = [StarIOPlugin_Communication sendCommands:commandData port:port];
        }
        @finally {
            if (port != nil && releasePort) {
                [SMPort releasePort:port];
            }
        }
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock unlock];
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:printResult];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    
}

-(void)openCashDrawer:(CDVInvokedUrlCommand *)command {
    NSLog(@"opening cash drawer");
    
    [self.commandDelegate runInBackground:^{
        NSString *portName = nil;
        SMPort *port = nil;
        BOOL releasePort = false;
        
        if (command.arguments.count > 0) {
            portName = [command.arguments objectAtIndex:0];
        }
        
        if (_starIoExtManager == nil || _starIoExtManager.port == nil) {
            port = [SMPort getPort:portName :@"" :10000];
            releasePort = true;
        } else {
            port = [_starIoExtManager port];
        }
        
        unsigned char openCashDrawerCommand = 0x07;
        
        NSData *commandData = [NSData dataWithBytes:&openCashDrawerCommand length:1];
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock lock];
        }
        
        BOOL printResult;
        
        @try {
            printResult = [StarIOPlugin_Communication sendCommands:commandData port:port];
        }
        @finally {
            if (port != nil && releasePort) {
                [SMPort releasePort:port];
            }
        }
        
        if (_starIoExtManager != nil) {
            [_starIoExtManager.lock unlock];
        }
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:printResult];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    
}

//Printer events
-(void)didPrinterCoverOpen {
    NSLog(@"printerCoverOpen");
    [self sendData:@"printerCoverOpen" data:nil];
}

-(void)didPrinterCoverClose {
    NSLog(@"printerCoverClose");
    [self sendData:@"printerCoverClose" data:nil];
}

-(void)didPrinterImpossible {
    NSLog(@"printerImpossible");
    [self sendData:@"printerImpossible" data:nil];
}

-(void)didPrinterOnline {
    NSLog(@"printerOnline");
    [self sendData:@"printerOnline" data:nil];
}

-(void)didPrinterOffline {
    NSLog(@"printerOffline");
    [self sendData:@"printerOffline" data:nil];
}

-(void)didPrinterPaperEmpty {
    NSLog(@"printerPaperEmpty");
    [self sendData:@"printerPaperEmpty" data:nil];
}

-(void)didPrinterPaperNearEmpty {
    NSLog(@"printerPaperNearEmpty");
    [self sendData:@"printerPaperNearEmpty" data:nil];
}

-(void)didPrinterPaperReady {
    NSLog(@"printerPaperReady");
    [self sendData:@"printerPaperReady" data:nil];
}


//Barcode reader events
-(void)didBarcodeReaderConnect {
    NSLog(@"barcodeReaderConnect");
    [self sendData:@"barcodeReaderConnect" data:nil];
}

-(void)didBarcodeDataReceive:(NSData *)data {
    NSLog(@"barcodeDataReceive");
    
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    const uint8_t *p = [data bytes];
    
    for (int i = 0; i < data.length; i++) {
        uint8_t ch = *(p + i);
        
        if(ch >= 0x20 && ch <= 0x7f) {
            [text appendFormat:@"%c", (char) ch];
        }
        else if (ch == 0x0d) { //carriage return
            //            text = [NSMutableString stringWithString:@""];
        }
    }
    
    [self sendData:@"barcodeDataReceive" data:text];
}

-(void)didBarcodeReaderImpossible {
    NSLog(@"barcodeReaderImpossible");
    [self sendData:@"barcodeReaderImpossible" data:nil];
}

//Cash drawer events
-(void)didCashDrawerOpen {
    NSLog(@"cashDrawerOpen");
    [self sendData:@"cashDrawerOpen" data:nil];
}
-(void)didCashDrawerClose {
    NSLog(@"cashDrawerClose");
    [self sendData:@"cashDrawerClose" data:nil];
}

- (void)handleOpenURL:(NSNotification *)notification
{
    NSLog(@"%@ handleOpenURL!", [self class]);
}

- (void)onAppTerminate
{
    NSLog(@"%@ onAppTerminate!", [self class]);
    if (_starIoExtManager != nil && _starIoExtManager.port != nil) {
        [_starIoExtManager disconnect];
    }
}

- (void)onMemoryWarning
{
    NSLog(@"%@ onMemoryWarning!", [self class]);
}

- (void)onReset
{
    NSLog(@"%@ onReset!", [self class]);
}

- (void)dispose
{
    NSLog(@"%@ dispose!", [self class]);
    if (_starIoExtManager != nil && _starIoExtManager.port != nil) {
        [_starIoExtManager disconnect];
    }
}

//Utilities

- (NSMutableDictionary*)portInfoToDictionary:(PortInfo *)portInfo {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[portInfo portName] forKey:@"portName"];
    [dict setObject:[portInfo macAddress] forKey:@"macAddress"];
    [dict setObject:[portInfo modelName] forKey:@"modelName"];
    return dict;
}

- (NSMutableDictionary*)portStatusToDictionary:(StarPrinterStatus_2)status {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithBool:status.coverOpen == SM_TRUE] forKey:@"coverOpen"];
    [dict setObject:[NSNumber numberWithBool:status.offline == SM_TRUE] forKey:@"offline"];
    [dict setObject:[NSNumber numberWithBool:status.overTemp == SM_TRUE] forKey:@"overTemp"];
    [dict setObject:[NSNumber numberWithBool:status.cutterError == SM_TRUE] forKey:@"cutterError"];
    [dict setObject:[NSNumber numberWithBool:status.receiptPaperEmpty == SM_TRUE] forKey:@"receiptPaperEmpty"];
    return dict;
}

- (void)sendData:(NSString *)dataType data:(NSString *)data {
    if (dataCallbackId != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:dataType forKey:@"dataType"];
        if (data != nil) {
            [dict setObject:data forKey:@"data"];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
    }
}

@end