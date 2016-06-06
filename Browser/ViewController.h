//
//  ViewController.h
//  Browser
//
//  Created by Alessandro Musto on 6/3/16.
//  Copyright © 2016 Lmusto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/**
 Replaces the web view with a fresh one, erasing all history. Also updates the URL field and toolbar buttons appropriately.
 */
- (void) resetWebView;


@end

