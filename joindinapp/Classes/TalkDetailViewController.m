//
//  TalkDetailViewController.m
//  joindinapp
//
//  Created by Kevin on 01/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TalkDetailViewController.h"


@implementation TalkDetailViewController

@synthesize talk;
@synthesize uiTitle;
@synthesize uiSpeaker;
@synthesize uiDate;
@synthesize uiDesc;
@synthesize uiRating;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	self.title = talk.title;
	self.uiTitle.text = talk.title;
	self.uiSpeaker.text = talk.speaker;
	
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"d MMM yyyy"];
	NSString *dateGiven = [outputFormatter stringFromDate:talk.given];
	[outputFormatter release];
	
	self.uiDate.text = dateGiven;
	self.uiDesc.text = talk.desc;
	
	NSLog(@"Talk rating is %d", self.talk.rating);
	if (self.talk.rating > 0 && self.talk.rating <= 5) {
		self.uiRating.hidden = NO;
		self.uiRating.image = [UIImage imageNamed:[NSString stringWithFormat:@"rating-%d.gif", talk.rating]];
	} else {
		self.uiRating.hidden = YES;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
    return cell;
}

- (void)dealloc {
    [super dealloc];
}


@end

