//
//  TravelEditViewController.m
//  Reiseabrechnung
//
//  Created by Martin Maier on 29/06/2011.
//  Copyright 2011 Martin Maier. All rights reserved.
//

#import "ParticipantEditViewController.h"
#import "Currency.h"
#import "TravelNotManaged.h"
#import "ReiseabrechnungAppDelegate.h"
#import "UIFactory.h"
#import "Country.h"
#import "GenericSelectViewController.h"
#import "ParticipantHelperCategory.h"
#import "CountryCell.h"
#import "TextEditViewController.h"
#import "AlignedStyle2Cell.h"
#import "ExchangeRate.h"
#import "NumberEditViewController.h"
#import "Style2ImageCell.h"
#import "ImageUtils.h"
#import "NotesEditViewController.h"
#import "ParticipantView.h"

static NSIndexPath *_nameIndexPath;
static NSIndexPath *_emailIndexPath;
static NSIndexPath *_weightIndexPath;
static NSIndexPath *_imageIndexPath;
static NSIndexPath *_notesIndexPath;
static NSIndexPath *_cashierIndexPath;

@interface ParticipantEditViewController ()
- (void)initIndexPaths;
- (void)updateAndFlash:(UIViewController *)viewController;
- (void)selectEmail:(NSString *)newEmail;
- (void)selectName:(NSString *)newName;
- (void)selectNotes:(NSString *)notes;
@end

@implementation ParticipantEditViewController

@synthesize name=_name, email=_email, weight=_weight, image=_image, notes=_notes;
@synthesize travel=_travel, participant=_participant;
@synthesize editDelegate=_editDelegate;
@synthesize imageActionSheet=_imageActionSheet;

- (id) initInManagedObjectContext:(NSManagedObjectContext *)context withTravel:(Travel *)travel withParticipant:(Participant *)participant {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: initInManagedObjectContext"];
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        [self initIndexPaths];
        
        _isFirstView = YES;
        
        _cellsToReloadAndFlash = [[[NSMutableArray alloc] init] retain];
        
        _context = [context retain];
        
        [UIFactory initializeTableViewController:self.tableView];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.travel = travel;
        self.participant = participant;
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        
        if (self.participant) {
        
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)] autorelease];
            self.title = NSLocalizedString(@"Edit Person", @"controller person edit title");  
            
        } else {
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done:)] autorelease];
            self.title = NSLocalizedString(@"Add Person", @"controller person add title");  
            
        }
        
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = [UIFactory createBackgroundViewWithFrame:self.view.frame];
        
        _toggleSwitch = [[UISwitch alloc] init];
        
        if (!participant) {
            
            self.notes = @"";
            self.name = @"";
            self.email = @"";
            self.weight = [NSNumber numberWithInt:1];
            self.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"]];
            _toggleSwitch.on = FALSE;
            
        } else {
            
            self.notes = participant.notes;
            self.name = participant.name;
            self.email = participant.email;
            self.weight = participant.weight;
            self.image = participant.image;
            _toggleSwitch.on = [self.travel.cashier isEqual:participant];

        }
        
        self.imageActionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"image iphone", @"alert image from iphone"), NSLocalizedString(@"image camera", @"alert image from camera"), nil] autorelease];
        self.imageActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

    }
    return self;
}

- (void)initIndexPaths {
    _nameIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
    _emailIndexPath = [[NSIndexPath indexPathForRow:1 inSection:0] retain];
    _weightIndexPath = [[NSIndexPath indexPathForRow:2 inSection:0] retain];
    _imageIndexPath = [[NSIndexPath indexPathForRow:3 inSection:0] retain];
    _notesIndexPath = [[NSIndexPath indexPathForRow:4 inSection:0] retain];
    _cashierIndexPath = [[NSIndexPath indexPathForRow:5 inSection:0] retain];
}


- (void)updateAndFlash:(UIViewController *)viewController {
    
    if (viewController == self && _viewAppeared) {
        
        [self.tableView beginUpdates];
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        [self.tableView endUpdates];
        
        for (id indexPath in _cellsToReloadAndFlash) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];                  
        }
        [_cellsToReloadAndFlash removeAllObjects];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: cellForRowAtIndexPath"];
    
    UITableViewCell *cell = nil;
    
    if ([indexPath isEqual:_nameIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil andNamedImage:@"user1.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Name", @"cell caption name");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.name;
        
    } else if ([indexPath isEqual:_emailIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil andNamedImage:@"mail.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"E-Mail", @"cell caption mail");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.email;
        
    } else if ([indexPath isEqual:_weightIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil andNamedImage:@"weight.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Default Weight", @"cell caption weight");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [self.weight stringValue];
                
    } else if ([indexPath isEqual:_imageIndexPath]) {
        
        Style2ImageCell *imageCell = [[[Style2ImageCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil andNamedImage:@"photo_portrait.png"] autorelease];
        imageCell.textLabel.text = NSLocalizedString(@"Image", @"cell caption image");
        imageCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        imageCell.rightImage = self.image;
        cell = imageCell;
        
    } else if ([indexPath isEqual:_notesIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil andNamedImage:@"notebook.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Notes", @"cell caption notes");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = self.notes;
        
    } else if ([indexPath isEqual:_cashierIndexPath]) {
        
        cell = [[[AlignedStyle2Cell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cashierToggleCell" andNamedImage:@"cashier.png"] autorelease];
        cell.textLabel.text = NSLocalizedString(@"Cashier", @"cell caption cashier");
        
        UIView *newSwitch= [[UIView alloc] initWithFrame:_toggleSwitch.frame];
        [newSwitch addSubview:_toggleSwitch];
        cell.accessoryView = newSwitch;
        [newSwitch release];
        
    } else {
        NSLog(@"no indexpath cell found for %@ ", indexPath);
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:_weightIndexPath] || [indexPath isEqual:_imageIndexPath]) {
        return NSLocalizedString(@"Reset", @"clear button");
    }
    return NSLocalizedString(@"Clear", @"delete button title clear text cell");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return ![indexPath isEqual:_cashierIndexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![indexPath isEqual:_cashierIndexPath]) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: commitEditingStyle"];
    
    if ([indexPath isEqual:_nameIndexPath]) {
        
        self.name = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_nameIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
        
        [self checkIfDoneIsPossible];
        
    } else if ([indexPath isEqual:_emailIndexPath]) {
        
        self.email = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_emailIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
        
    } else if ([indexPath isEqual:_weightIndexPath]) {
        
        self.weight = [NSNumber numberWithInt:1];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_weightIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
    
    } else if ([indexPath isEqual:_imageIndexPath]) {
    
        self.image = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage" ofType:@"png"]];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_imageIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
        
    } else if ([indexPath isEqual:_notesIndexPath]) {
        
        self.notes = @"";
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_notesIndexPath] withRowAnimation:[UIFactory commitEditingStyleRowAnimation]];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: didSelectRowAtIndexPath"];
    
    if ([indexPath isEqual:_nameIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.name target:self selector:@selector(selectName:) andNamedImage:@"user1.png"]; 
        textEditViewController.title = NSLocalizedString(@"Name", @"controller title edit name");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release];            
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ([indexPath isEqual:_emailIndexPath]) {
        
        TextEditViewController *textEditViewController = [[TextEditViewController alloc] initWithText:self.email target:self selector:@selector(selectEmail:) andNamedImage:@"mail.png"]; 
        textEditViewController.title = NSLocalizedString(@"E-Mail", @"controller title edit mail");
        [textEditViewController setKeyBoardType:UIKeyboardTypeEmailAddress];
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release]; 
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ([indexPath isEqual:_weightIndexPath]) {
        
        NumberEditViewController *numberEditViewController = [[NumberEditViewController alloc] initWithNumber:self.weight withDecimals:YES andNamedImage:@"weight.png"  description:NSLocalizedString(@"weight info",@"weight description") target:self selector:@selector(selectWeight:)]; 
        numberEditViewController.title = NSLocalizedString(@"Weight", @"controller title edit weight");
        numberEditViewController.allowZero = NO;
        numberEditViewController.allowNull = NO;
        [self.navigationController pushViewController:numberEditViewController animated:YES];
        [numberEditViewController release];  
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if ([indexPath isEqual:_imageIndexPath]) {
        
        [self.imageActionSheet showInView:self.view];           
        
    } else if ([indexPath isEqual:_notesIndexPath]) {
        
        NotesEditViewController *textEditViewController = [[NotesEditViewController alloc] initWithText:self.notes target:self selector:@selector(selectNotes:)]; 
        textEditViewController.title = NSLocalizedString(@"Notes", @"controller title edit notes");
        [self.navigationController pushViewController:textEditViewController animated:YES];
        [textEditViewController release]; 
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } 
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: actionSheet clickedButtonAtIndex"];
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init]; 
        picker.delegate = self; 
        picker.allowsEditing = NO;
        
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;     
            } else {
                [self.tableView deselectRowAtIndexPath:_imageIndexPath animated:YES];
            }
        } else {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;     
            } else {
                [self.tableView deselectRowAtIndexPath:_imageIndexPath animated:YES];
            }        
        }
        [self presentViewController:picker animated:YES completion:NULL];
        [picker release];
        
    } else {
        [self.tableView deselectRowAtIndexPath:_imageIndexPath animated:YES];
    }
}

#pragma mark UIImagePickerControllerDelegate

#define IMAGE_WIDTH 96

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    UIImage *origImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.image = UIImagePNGRepresentation([origImage imageByScalingToSize:CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH)]);
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_imageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [_cellsToReloadAndFlash addObject:_imageIndexPath];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    
    [self.tableView deselectRowAtIndexPath:_imageIndexPath animated:YES];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateAndFlash:self];
}

#pragma mark Select Items

- (void)selectName:(NSString *)newName {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: selectName"];
    
    if (![newName isEqualToString:self.name]) {
        self.name = newName;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_nameIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_cellsToReloadAndFlash addObject:_nameIndexPath];
    }
}

- (void)selectEmail:(NSString *)newEmail {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: selectEmail"];
    
    if (![newEmail isEqualToString:self.email]) {
        self.email = newEmail;
        [_cellsToReloadAndFlash addObject:_emailIndexPath];
    }
}

- (void)selectWeight:(NSNumber *)newWeight {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: selectWeight"];
    
    if (![newWeight isEqualToNumber:self.weight]) {
        self.weight = newWeight;
        [_cellsToReloadAndFlash addObject:_weightIndexPath];
    }
}

- (void)selectNotes:(NSString *)notes {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: selectNotes"];
    
    if (![notes isEqual:self.notes]) {
        self.notes = notes;
        [_cellsToReloadAndFlash addObject:_notesIndexPath];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: done"];
    
    if (!self.participant) {
        self.participant = [NSEntityDescription insertNewObjectForEntityForName: @"Participant" inManagedObjectContext:_context];
        [self.travel addParticipantsObject:self.participant];
    }
    
    self.participant.name = self.name;
    self.participant.notes = self.notes;
    self.participant.email = self.email;
    self.participant.weight = [NSDecimalNumber decimalNumberWithDecimal:[self.weight decimalValue]];
    self.participant.image = self.image;
    self.participant.imageSmall = [Participant createThumbnail:self.image];
    
    BOOL cashierChanged = FALSE;
    if (_toggleSwitch.on) {
        self.travel.cashier = self.participant;
        cashierChanged = TRUE;
    } else {
        if ([self.travel.cashier isEqual:self.participant]) {
            self.travel.cashier = nil;
            cashierChanged = TRUE;
        }
    }
    
    [ParticipantView evictCache];
    
    [ReiseabrechnungAppDelegate saveContext:_context];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self.editDelegate participantEditFinished:self.participant wasSaved:YES cashierChanged:cashierChanged];

}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    [Crittercism leaveBreadcrumb:@"SummarySortViewController: cancel"];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self.editDelegate participantEditFinished:self.participant wasSaved:NO cashierChanged:NO];
}

- (void)checkIfDoneIsPossible {
    
    if ([self.name length] > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }    
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    
    _viewAppeared = YES;
    
    if (!self.participant && _isFirstView) {
        [self updateAndFlash:self];
        _isFirstView = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self checkIfDoneIsPossible];
}

#pragma mark - Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    
    [_context release];
    [_cellsToReloadAndFlash release];
    [_travel release];
    
    [_nameIndexPath release];
    [_emailIndexPath release];
    [_weightIndexPath release];
    [_imageIndexPath release];
    [_notesIndexPath release];
    [_image release];
    [_toggleSwitch release];
    
    [_participant release];
    [_imageActionSheet release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
