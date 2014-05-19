//
//  StarPrint.m
//  Star Print
//
//  Created by Shashwat Triapthi (github.com/goforgold) on 19 May 2014.
//  Copyright 2014 Shashwat Triapthi. All rights reserved.
//  MIT licensed
//

#import "StarPrint.h"

@interface StarPrint (Private)
-(void) doPrint;
-(void) callbackWithFuntion:(NSString *)function withData:(NSString *)value;
- (BOOL) isPrintServiceAvailable;
@end

@implementation StarPrint

//@synthesize successCallback, failCallback, printHTML, dialogTopPos, dialogLeftPos;
@synthesize successCallback, failCallback, portName, printContent;

/*
 Is printing available. Callback returns true/false if printing is available/unavailable.
 */
 - (void) isPrintingAvailable:(CDVInvokedUrlCommand*)command{
    NSUInteger argc = [command.arguments count];
    
    if (argc < 1) {
        return;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:([self isPrintServiceAvailable] ? YES : NO)];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) print:(CDVInvokedUrlCommand*)command{
    NSUInteger argc = [command.arguments count];
    NSLog(@"Array contents: %@", command.arguments);
    if (argc < 1) {
        return;
    }
    
    self.portName = [command.arguments objectAtIndex:0];
    self.printContent = [command.arguments objectAtIndex:1];
    
    //NSLog(@"msg: %@", self.msg);
    
    
    //unsigned char printCommand[] = {0x41, 0x42, 0x43, 0x44, 0x1B, 0x7A, 0x00, 0x1B, 0x64, 0x02};
    unsigned char* printCommand = (unsigned char*) [self.printContent UTF8String];
    uint bytesWritten = 0;
    StarPrinterStatus_2 starPrinterStatus;
    SMPort *port = nil;
    @try
    {
        port = [SMPort getPort:@"BT:" :@"MINI" :10000];
        //Start checking the completion of printing
        [port beginCheckedBlock:&starPrinterStatus :2];
        if (starPrinterStatus.offline == SM_TRUE)
        {
            //There was an error writing to the port
        }
        while (bytesWritten < sizeof (printCommand)) {
            bytesWritten += [port writePort: printCommand : bytesWritten : sizeof (printCommand) - bytesWritten];
        }
        //End checking the completion of printing
        [port endCheckedBlock:&starPrinterStatus :2];
        if (starPrinterStatus.offline == SM_TRUE)
        {
            //There was an error writing to the port
        }
    }
    @catch (PortException *ex)
    {
        //There was an error writing to the port
    }
    @finally
    {
        [SMPort releasePort:port];
    }
    
    CDVPluginResult* pluginResult = nil;
    
    BOOL isError = NO;
    
    if (isError) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[NSString stringWithFormat:@"{success: false, available: true, error: \"%@\"}", @"iOS Error"]];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"{success: true}"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(BOOL) isPrintServiceAvailable{
    
    Class myClass = NSClassFromString(@"UIPrintInteractionController");
    if (myClass) {
        UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
        return (controller != nil) && [UIPrintInteractionController isPrintingAvailable];
    }
    
    
    return NO;
}

@end
